#include <stddef.h>
#include <stdint.h>

#include "crc32.h"
#include "mem_map.h"

#define PHATIC (0x11)

#define ACK (0x06)
#define NAK (0x15)

// Update these macros for big-endian systems if needed.
#define SEND_VAR(var) (send((uint8_t *) &(var), sizeof(var)))
#define RECV_VAR(var) (recv((uint8_t *) &(var), sizeof(var)))

typedef unsigned int word_t;

static const char greating[] =
    "Greetings from the ADAM bootloader\n"
    "Compiled on: " __DATE__ " at " __TIME__ "\n"
    "LIRMM - Universite de Montpellier, CNRS - France\n";

static void write_cmd(void);
static void read_cmd(void);
static void boot_cmd(void);
static void default_cmd(void);

static void send_str(const char *str);
static void send(uint8_t *data, uint16_t  len);
static void recv(uint8_t *data, uint16_t  len);

static uint32_t send_crc;
static uint32_t recv_crc;

int main()
{
    uint8_t phatic;
    uint8_t cmd;

    // Resume GPIO0
    SYSCTRL.PMR_GPIO0 = 1;
    while(SYSCTRL.PMR_GPIO0);

    // Resume UART0
    SYSCTRL.PMR_UART0 = 1;
    while(SYSCTRL.PMR_UART0);

    GPIO0.MODER = ~0;
    GPIO0.ODR = 0;

    UART0.BRR = 434; // 115200 @ 50MHz 
    UART0.CR  = 0x807; // No parity, 1 stop, 8 data
    
    generate_crc32_table();

    send_str(greating);

    phatic = PHATIC;
    SEND_VAR(phatic);

    while(1) {
        do {
            RECV_VAR(phatic);
        } while(phatic != PHATIC);

        RECV_VAR(cmd);

        GPIO0.ODR++;

        switch(cmd) {
            case 0x00: // WRITE
                write_cmd();
                break;

            case 0x01: // READ
                read_cmd();
                break;

            case 0x02: // BOOT
                boot_cmd();
                break;

            default:
                default_cmd();
                break;
        }
    }

    return 0;
}

void write_cmd(void)
{
    uint64_t address;
    uint16_t length;

    word_t word;
    uint8_t byte;
    
    uint32_t crc_remote;
    uint32_t crc_local;
    
    uint8_t resp;

    recv_crc = 0;
    RECV_VAR(address);
    RECV_VAR(length);
    crc_local = recv_crc;
    RECV_VAR(crc_remote);

    resp = (crc_local == crc_remote) ? ACK : NAK;
    SEND_VAR(resp);
    if(resp != ACK) return;

    recv_crc = 0;
    while(length > 0) {
        if(address % sizeof(word) == 0 && length >= sizeof(word)) {
            // alligned word access
            RECV_VAR(word);
            *(volatile word_t *) (word_t) address = word;
            address += sizeof(word);
            length -= sizeof(word);
        } else {
            // byte access
            RECV_VAR(byte);
            *(volatile uint8_t *) (word_t) address = byte;
            address += sizeof(byte);
            length -= sizeof(byte); 
        }
    }
    crc_local = recv_crc;
    RECV_VAR(crc_remote);

    resp = (crc_local == crc_remote) ? ACK : NAK;
    SEND_VAR(resp);
    if(resp != ACK) return;
}

void read_cmd(void)
{
    uint64_t address;
    uint16_t length;

    word_t word;
    uint8_t byte;

    uint32_t crc_remote;
    uint32_t crc_local;

    uint8_t resp;

    recv_crc = 0;
    RECV_VAR(address);
    RECV_VAR(length);
    crc_local = recv_crc;
    RECV_VAR(crc_remote);

    resp = (crc_local == crc_remote) ? ACK : NAK;
    SEND_VAR(resp);
    if(resp != ACK) return;

    send_crc = 0;
    while(length > 0) {
        if (address % sizeof(word) == 0 && length > sizeof(word)) {
            // alligned word access
            word = *(volatile word_t *) (word_t) address;
            SEND_VAR(word);
            address += sizeof(word);
            length -= sizeof(word);
        } else {
            // byte access
            byte = *(volatile uint8_t *) (word_t) address;
            SEND_VAR(byte);
            address += sizeof(byte);
            length -= sizeof(byte); 
        }
    }
    crc_local = send_crc;
    SEND_VAR(crc_local);
}

void boot_cmd(void)
{
    uint64_t address;
    uint32_t crc_remote;
    uint32_t crc_local;
    uint8_t resp;

    recv_crc = 0;
    RECV_VAR(address);
    crc_local = recv_crc;
    RECV_VAR(crc_remote);

    resp = (crc_local == crc_remote) ? ACK : NAK;
    SEND_VAR(resp);
    if(resp != ACK) return;

    /*
     * The following code is temporary because the self-reset does not
     * behave as expected.
     */
    
    while(!UART0.TBE);
    asm volatile ("jalr %0" : : "r"((uint32_t) address));

    // SYSCTRL.BAR0 = address;
    // SYSCTRL.SSR0_SR = 1;
    // while(1) asm volatile ("wfi");
}

void default_cmd(void)
{
    uint8_t resp = NAK;
    SEND_VAR(resp);
}

void send_str(const char *str)
{
    while(*str != '\0') {
        while(!UART0.TBE);
        UART0.DR = *str;
        str++;
    }
}

void send(uint8_t *data, uint16_t len)
{
    for(uint16_t i = 0; i < len; i++) {
        while(!UART0.TBE);
        UART0.DR = data[i];
    }

    send_crc = crc32(data, len, send_crc);
}

void recv(uint8_t *data, uint16_t len)
{
    for(uint16_t i = 0; i < len; i++) {
        while(!UART0.RBF);
        data[i] = UART0.DR;
    }

    recv_crc = crc32(data, len, recv_crc);
}