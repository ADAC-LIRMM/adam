/*
 * Copyright 2025 LIRMM
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*  Hawkeye with Belady's Algorithm Replacement Policy
    Code for Hawkeye configurations of 1 and 2 in Champsim */

#include "hawkeye.h"

struct OPTgen{
    unsigned int liveness_intervals[OPTGEN_SIZE];
    uint32_t num_cache;
    uint32_t access;
    unsigned int cache_size;
};

uint8_t rrip[LLC_SETS][LLC_WAYS];
uint16_t set_timer[LLC_SETS];   //64 sets, where 1 timer is used for every set
uint8_t PC_Map[PCMAP_SIZE];
struct OPTgen optgen_occup_vector[LLC_SETS];   //64 vectors, 128 entries each
uint64_t sample_signature[LLC_SETS][LLC_WAYS];

//struct HISTORY cache_history_sampler[SAMPLER_SETS][LLC_WAYS];
bool cache_history_sampler_valid[SAMPLER_SETS][LLC_WAYS];
uint64_t cache_history_sampler_address[SAMPLER_SETS][LLC_WAYS];
uint64_t cache_history_sampler_tag[SAMPLER_SETS][LLC_WAYS];
uint64_t cache_history_sampler_PCval[SAMPLER_SETS][LLC_WAYS];
uint32_t cache_history_sampler_previousVal[SAMPLER_SETS][LLC_WAYS];
uint8_t cache_history_sampler_lru[SAMPLER_SETS][LLC_WAYS];


//Mathematical functions needed for sampling set
#define bitmask(l) (((l) == 64) ? (unsigned long long)(-1LL) : ((1LL << (l))-1LL))
#define bits(x, i, l) (((x) >> (i)) & bitmask(l))
#define SAMPLED_SET(set) (bits(set, 0 , 6) == bits(set, ((unsigned long long)log2(LLC_SETS) - 6), 6) )  //Helper function to sample 64 sets for each core

void InitReplacementState(uint8_t rrip[LLC_SETS][LLC_WAYS],uint64_t sample_signature[LLC_SETS][LLC_WAYS],uint16_t set_timer[LLC_SETS],
		struct OPTgen optgen_occup_vector[LLC_SETS],
		//struct HISTORY cache_history_sampler[SAMPLER_SETS][LLC_WAYS],
		bool cache_history_sampler_valid[SAMPLER_SETS][LLC_WAYS],
		uint64_t cache_history_sampler_address[SAMPLER_SETS][LLC_WAYS],
		uint64_t cache_history_sampler_tag[SAMPLER_SETS][LLC_WAYS],
		uint64_t cache_history_sampler_PCval[SAMPLER_SETS][LLC_WAYS],
		uint32_t cache_history_sampler_previousVal[SAMPLER_SETS][LLC_WAYS],
		uint8_t cache_history_sampler_lru[SAMPLER_SETS][LLC_WAYS],
		uint8_t PC_Map[PCMAP_SIZE]);
unsigned long long CRC(unsigned long long address);
uint8_t GetVictim (uint8_t rrip[LLC_SETS][LLC_WAYS], uint64_t sample_signature[LLC_SETS][LLC_WAYS],uint8_t PC_Map[PCMAP_SIZE],
		uint32_t set, uint8_t way, uint8_t hit);
void UpdateReplacementState (uint8_t rrip[LLC_SETS][LLC_WAYS],uint64_t sample_signature[LLC_SETS][LLC_WAYS],
		uint32_t set, uint8_t wayU, uint64_t paddr,  uint64_t PC, uint8_t hit, uint16_t set_timer[LLC_SETS],
		struct OPTgen optgen_occup_vector[LLC_SETS],
		bool cache_history_sampler_valid[SAMPLER_SETS][LLC_WAYS],
		uint64_t cache_history_sampler_tag[SAMPLER_SETS][LLC_WAYS],
		uint64_t cache_history_sampler_PCval[SAMPLER_SETS][LLC_WAYS],
		uint32_t cache_history_sampler_previousVal[SAMPLER_SETS][LLC_WAYS],
		uint8_t cache_history_sampler_lru[SAMPLER_SETS][LLC_WAYS],
		uint8_t PC_Map[PCMAP_SIZE]
		);
bool is_cache(uint32_t val, uint32_t endVal, unsigned int cache_size, uint32_t set,struct OPTgen optgen_occup_vector[LLC_SETS]);
void update_cache_history(uint32_t sample_set, unsigned int currentVal,uint8_t cache_history_sampler_lru[SAMPLER_SETS][LLC_WAYS]);
uint32_t modulo(uint64_t a, int b);
uint32_t fast_mod_shift6_350(uint64_t addr);
//----------------------------------------------------------------------
// hawkeye
//----------------------------------------------------------------------
uint8_t hawkeye (bool init, uint64_t paddr, uint32_t set, uint64_t pc, uint8_t way, uint8_t hit)
{
	bool b_return;
	uint8_t victimWay;
	uint8_t result;


	if (init){
	    InitReplacementState(rrip,sample_signature,set_timer,optgen_occup_vector,cache_history_sampler_valid,
				cache_history_sampler_address,cache_history_sampler_tag,cache_history_sampler_PCval,cache_history_sampler_previousVal,
				cache_history_sampler_lru,PC_Map);
	}
	else
	{
		victimWay = GetVictim(rrip,sample_signature,PC_Map,set,way,hit); // if miss computes victimWay

		UpdateReplacementState(rrip,sample_signature,set,victimWay,paddr,pc,hit,set_timer,optgen_occup_vector,cache_history_sampler_valid,
			cache_history_sampler_tag,cache_history_sampler_PCval,cache_history_sampler_previousVal,
			cache_history_sampler_lru,PC_Map);
	}
	return victimWay;
}

//-------------------------------------------------------------------------------------------------------------------------------------
// Initialize replacement state
//-------------------------------------------------------------------------------------------------------------------------------------
void InitReplacementState(uint8_t rrip[LLC_SETS][LLC_WAYS],uint64_t sample_signature[LLC_SETS][LLC_WAYS],uint16_t set_timer[LLC_SETS],
		struct OPTgen optgen_occup_vector[LLC_SETS],
		//struct HISTORY cache_history_sampler[SAMPLER_SETS][LLC_WAYS],
		bool cache_history_sampler_valid[SAMPLER_SETS][LLC_WAYS],
		uint64_t cache_history_sampler_address[SAMPLER_SETS][LLC_WAYS],
		uint64_t cache_history_sampler_tag[SAMPLER_SETS][LLC_WAYS],
		uint64_t cache_history_sampler_PCval[SAMPLER_SETS][LLC_WAYS],
		uint32_t cache_history_sampler_previousVal[SAMPLER_SETS][LLC_WAYS],
		uint8_t cache_history_sampler_lru[SAMPLER_SETS][LLC_WAYS],
		uint8_t PC_Map[PCMAP_SIZE])
{
    static bool initialized = false;

    if (!initialized) {
            initialized = true;
            for (int i=0; i<LLC_SETS; i++) {
                        set_timer[i] = 0;
                	}
            for(int i = 0; i < PCMAP_SIZE; i++){
            	        PC_Map[i] = (MAX_PCMAP + 1)/2;
            	}

            for (int i=0; i<LLC_SETS; i++) {
                    for (int j=0; j<LLC_WAYS; j++) {
                    	rrip[i][j] = MAXRRIP;
                        sample_signature[i][j] = 0;
                    }
                }
            for (int i=0; i<LLC_SETS; i++) {
                optgen_occup_vector[i].num_cache = 0;
                optgen_occup_vector[i].access = 0;
                optgen_occup_vector[i].cache_size = 6; //LLC_WAYS-2;

                for (int k=0; k<OPTGEN_SIZE; k++)
                {
                	optgen_occup_vector[i].liveness_intervals[k] = 0;
                }
            }

            for(int i = 0; i < SAMPLER_SETS; i++){
             for(int j = 0; j < LLC_WAYS; j++){
            	 cache_history_sampler_valid[i][j] = false;
            	 cache_history_sampler_address[i][j] = 0;
            	 cache_history_sampler_tag[i][j] = 0;
            	 cache_history_sampler_PCval[i][j] = 0;
            	 cache_history_sampler_previousVal[i][j] = 0;
            	 cache_history_sampler_lru[i][j] = 0;
                }
            }
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------
// GetVictim
//-------------------------------------------------------------------------------------------------------------------------------------
// Find replacement victim
// Return value should be 0 ~ 15 or 16 (bypass)
uint8_t GetVictim (uint8_t rrip[LLC_SETS][LLC_WAYS], uint64_t sample_signature[LLC_SETS][LLC_WAYS],
		uint8_t PC_Map[PCMAP_SIZE],
		uint32_t set, uint8_t way, uint8_t hit)
{
	int victim=-1;
	uint8_t i;
	bool maxrrip_true;
	uint8_t max_rrpv;

	if (hit) victim = way;
	else {

	maxrrip_true = false;

    //Find the line with RRPV of 7 in that set
    for(i = 0; i < LLC_WAYS; i++){
        if(rrip[set][i] == MAXRRIP){
        	if (maxrrip_true == false)
        		{
        			victim = i;
        			maxrrip_true = true;
        		}
        }
    }

    if (maxrrip_true == false)
    {
    	//If no RRPV of 7, then we find next highest RRPV value (oldest cache-friendly line)
//    	int32_t victim = -1;

    	max_rrpv = 0;
    	for(i = 0; i < LLC_WAYS; i++){
    		if(rrip[set][i] >= max_rrpv){
    			max_rrpv = rrip[set][i];
    			victim = i;
    		}
    	}

    	//Asserting that LRU victim is not -1
    	//Predictor will be trained negatively on evictions
    	if(SAMPLED_SET(set) && (victim != -1) ){
    		uint32_t result = CRC(sample_signature[set][victim]) % PCMAP_SIZE;
            if (PC_Map[result] != 0) PC_Map[result] = PC_Map[result] -1 ;
            else PC_Map[result]=0;
    	}
    }// first
	}
    return victim;
}

//-------------------------------------------------------------------------------------------------------------------------------------
// UpdateReplacementState
//-------------------------------------------------------------------------------------------------------------------------------------
// Called on every cache hit and cache fill
void UpdateReplacementState (uint8_t rrip[LLC_SETS][LLC_WAYS],uint64_t sample_signature[LLC_SETS][LLC_WAYS],
		uint32_t set, uint8_t wayU, uint64_t paddr, uint64_t PC, uint8_t hit, uint16_t set_timer[LLC_SETS],
		struct OPTgen optgen_occup_vector[LLC_SETS],
		//struct HISTORY cache_history_sampler[SAMPLER_SETS][LLC_WAYS],
		bool cache_history_sampler_valid[SAMPLER_SETS][LLC_WAYS],
		uint64_t cache_history_sampler_tag[SAMPLER_SETS][LLC_WAYS],
		uint64_t cache_history_sampler_PCval[SAMPLER_SETS][LLC_WAYS],
		uint32_t cache_history_sampler_previousVal[SAMPLER_SETS][LLC_WAYS],
		uint8_t cache_history_sampler_lru[SAMPLER_SETS][LLC_WAYS],
		uint8_t PC_Map[PCMAP_SIZE]
		)
{
    uint32_t i;
    uint8_t way;
    uint64_t result,sample_tag;
    uint32_t currentVal,previousVal;
    uint32_t sample_set ;
    uint8_t retValue;
    bool prediction;
    uint8_t isMaxVal;
    bool isWrap;
    bool cache;


    paddr = (paddr >> 6) << 6;
    way = wayU;

    if (PC == 0)
    {
    	return;
    }
    else
    {

    //Only if we are using sampling sets for OPTgen
    if(SAMPLED_SET(set)){
        currentVal = set_timer[set] % OPTGEN_SIZE;
        sample_tag = CRC(paddr >> 12) % 256;
        sample_set = modulo( (paddr >> 6),350);
        //sample_set = fast_mod_shift6_350(paddr);

        bool flag = false;
        for (int i=0; i<LLC_WAYS; i++){
        	if ( cache_history_sampler_tag[sample_set][i] == sample_tag ){ // if found the tag, store the way
        		 flag = true;
        		 way = i;
        		 }
        	}
        if(flag) {// line has been used before
            unsigned int current_time = set_timer[set];
            if(current_time < cache_history_sampler_previousVal[sample_set][way]){
                current_time += TIMER_SIZE;
            }
            previousVal = cache_history_sampler_previousVal[sample_set][way] % OPTGEN_SIZE;

            if (  (current_time - cache_history_sampler_previousVal[sample_set][way]) > OPTGEN_SIZE ) isWrap = true;
            else isWrap = false;


            //Train predictor positively for last PC value that was prefetched

    	    cache = is_cache(currentVal, previousVal,6,set,optgen_occup_vector);
     		result = CRC(cache_history_sampler_PCval[sample_set][way]) % PCMAP_SIZE;

     		if (!isWrap && cache) {
             		if (PC_Map[result] < MAX_PCMAP) PC_Map[result] = PC_Map[result] + 1 ;
             		else PC_Map[result] = MAX_PCMAP;
            }
            //Train predictor negatively since OPT did not cache this line
            else{
                     	if (PC_Map[result] != 0) PC_Map[result] = PC_Map[result] -1 ;
                     	else PC_Map[result] = 0;
                	}

            //optgen_occup_vector[set].set_access(currentVal);
            optgen_occup_vector[set].access++;
            optgen_occup_vector[set].liveness_intervals[currentVal] = 0;

            //Update cache history
            update_cache_history(sample_set, cache_history_sampler_lru[sample_set][way],cache_history_sampler_lru);
        }// if flag (tag found)
        //If line has not been used before, mark as prefetch or demand
//        else if(!flag){
        else {
            //If sampling, find victim from cache
            bool flag_cache_full = true;
            for (int i=0; i<LLC_WAYS; i++){
            	if ( (cache_history_sampler_valid[sample_set][i] == 0) && (flag_cache_full == true) ){	// cache is no full
            		cache_history_sampler_valid[sample_set][i] = 1;
            		cache_history_sampler_PCval[sample_set][i]=PC;
            		cache_history_sampler_previousVal[sample_set][i]=0;
            		cache_history_sampler_lru[sample_set][i]=0;
            		cache_history_sampler_tag[sample_set][i]=sample_tag;
            		way = i;
            		flag_cache_full = false;
            		}
            	}

            if (flag_cache_full == true) {	// cache is full, we must evict the way with lru=7
            	for (int i=0; i<LLC_WAYS; i++){
           		if (cache_history_sampler_lru[sample_set][i] == 7) {
            			cache_history_sampler_valid[sample_set][i] = 1;
            			cache_history_sampler_PCval[sample_set][i]=PC;
            			cache_history_sampler_previousVal[sample_set][i]=0;
            			cache_history_sampler_lru[sample_set][i]=0;
            			cache_history_sampler_tag[sample_set][i]=sample_tag;
            			}
            		}
            	}
            //If preftech, mark it as a prefetching or if not, just set the demand access
            optgen_occup_vector[set].access++;
            optgen_occup_vector[set].liveness_intervals[currentVal] = 0;


            //Update cache history
            update_cache_history(sample_set, SAMPLER_HIST-1,cache_history_sampler_lru);
        }

        //Update the sample with time and PC
        cache_history_sampler_previousVal[sample_set][way] = set_timer[set];
        cache_history_sampler_PCval[sample_set][way] = PC;
        cache_history_sampler_lru[sample_set][way] = 0;
        set_timer[set] = (set_timer[set] + 1) % TIMER_SIZE;
    }//SAMPLED_SET

    //Retrieve Hawkeye's prediction for line
    result = CRC(PC) % PCMAP_SIZE;
    if (PC_Map[result] < ((MAX_PCMAP+1)/2)) prediction = false; // cache averse
    else prediction = true;	// cache friendly

    sample_signature[set][wayU] = PC;
    //Fix RRIP counters with correct RRPVs and age accordingly

    if(!prediction){	// cache averse
        rrip[set][wayU] = MAXRRIP;
    }
    else{ // cache friendly
        rrip[set][wayU] = 0;
        if(!hit){ // miss
            //Verifying RRPV of lines has not saturated

            isMaxVal = 0;
            for(uint32_t i = 0; i < LLC_WAYS; i++){
//                if( (rrip[set][i] == MAXRRIP-1) && (isMaxVal == false)){
                if( rrip[set][i] == (MAXRRIP-1)){
                    isMaxVal = 1;
                }
            }

            //Aging cache-friendly lines that have not saturated
            for(uint32_t i = 0; i < LLC_WAYS; i++){
                if(!isMaxVal && rrip[set][i] < (MAXRRIP-1)){
                    rrip[set][i]++;
                }
            }
        }
        rrip[set][wayU] = 0;
    }

    }// PC != 0
}

//-------------------------------------------------------------------------------------------------------------------------------------
// CRC
//-------------------------------------------------------------------------------------------------------------------------------------
unsigned long long CRC(unsigned long long address){
	unsigned long long CRCPolynomial = 3988292384ULL;  //Decimal value for 0xEDB88320 hex value
    unsigned long long result_CRC = address;
    CRC_label0:for(unsigned int i = 0; i < 32; i++ )
    {
    	if((result_CRC & 1 ) == 1 ){
    		result_CRC = (result_CRC >> 1) ^ CRCPolynomial;
    	}
    	else{
    		result_CRC >>= 1;
    	}
    }
    return result_CRC;
}

//-------------------------------------------------------------------------------------------------------------------------------------
// is_cache
//-------------------------------------------------------------------------------------------------------------------------------------
//Return if hit or miss
bool is_cache(uint32_t val, uint32_t endVal, unsigned int cache_size, uint32_t set,struct OPTgen optgen_occup_vector[LLC_SETS]){
        bool cache = true;
        unsigned int count = endVal;

    if (endVal < val)
    {
        for (int i=endVal;i<val;i++){
        	printf("\n OPTGEN i=%d optgen_occup_vector[set].liveness_intervals[i] = %d", i,optgen_occup_vector[set].liveness_intervals[i]);
             if(optgen_occup_vector[set].liveness_intervals[i] >= cache_size){
                cache = false;
            }
        }
    }
    else
    {
        for (int i=endVal;i<OPTGEN_SIZE;i++){
         	printf("\n OPTGEN i=%d optgen_occup_vector[set].liveness_intervals[i] = %d", i,optgen_occup_vector[set].liveness_intervals[i]);
              if(optgen_occup_vector[set].liveness_intervals[i] >= cache_size){
                 cache = false;
             }
         }
        for (int i=0;i<val;i++){
         	printf("\n OPTGEN i=%d optgen_occup_vector[set].liveness_intervals[i] = %d", i,optgen_occup_vector[set].liveness_intervals[i]);
              if(optgen_occup_vector[set].liveness_intervals[i] >= cache_size){
                 cache = false;
             }
         }

    }

    if(cache){
        if (endVal < val)
        {
            for(int i=endVal; i<val; i++){
                optgen_occup_vector[set].liveness_intervals[i]++;
            }
        }
        else
        {
            for(int i=endVal; i<OPTGEN_SIZE; i++){
                optgen_occup_vector[set].liveness_intervals[i]++;
            }
            for(int i=0; i<val; i++){
                optgen_occup_vector[set].liveness_intervals[i]++;
            }
        }
        optgen_occup_vector[set].num_cache++;
    }
    return cache;
}

//-------------------------------------------------------------------------------------------------------------------------------------
// update_cache_history
//-------------------------------------------------------------------------------------------------------------------------------------
//Helper function for "UpdateReplacementState" to update cache history
void update_cache_history(uint32_t sample_set, unsigned int currentVal,uint8_t cache_history_sampler_lru[SAMPLER_SETS][LLC_WAYS]){
     		for(int i = 0; i < 8; i++){
     			if (cache_history_sampler_lru[sample_set][i] < currentVal){
     				cache_history_sampler_lru[sample_set][i]++;
     				}
     		}
}

uint32_t modulo(uint64_t a, int b) {
    if (b == 0) return 0; // protection division par zéro

    int quotient = a / b;
    return a - (quotient * b);
}

/*
uint32_t fast_mod_shift6_350(uint64_t addr)
{
	uint64_t x;
	ap_uint<128> prod;
	uint64_t q;
	uint32_t r;
	ap_uint<128> M;
	uint64_t val;

	x = addr >> 6;

	M = ((ap_uint<128>)0x3D4D8F0C01BB6F0ULL << 64) | (ap_uint<128>)0x908035727EB919C5ULL;

	prod = (ap_uint<128>)x * M;
	q = (uint64_t)(prod >> 128);
	val = x - q*350;
	if (val >= 350) val -= 350;

	r = (uint32_t)val;

	return r;
}
*/
