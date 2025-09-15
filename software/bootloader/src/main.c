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

#include <stddef.h>
#include <stdint.h>

#include "crc32.h"
#include "adam_ral.h"

#define PHATIC (0x11)

#define ACK (0x06)
#define NAK (0x15)

// Update these macros for big-endian systems if needed.
#define SEND_VAR(var) (send((uint8_t *) &(var), sizeof(var)))
#define RECV_VAR(var) (recv((uint8_t *) &(var), sizeof(var)))

static void hw_init(void);

typedef unsigned int word_t;

static const char greating[] =
    "Greetings from the ADAM bootloader\n\r"
    "Compiled on: " __DATE__ " at " __TIME__ "\n\r"
    "LIRMM - Universite de Montpellier, CNRS - France\n\r";

static void write_cmd(void);
static void read_cmd(void);
static void boot_cmd(void);
static void default_cmd(void);

static void send(const uint8_t *data, uint16_t  len);
static void recv(uint8_t *data, uint16_t  len);

// static uint32_t send_crc;  // Commented out
// static uint32_t recv_crc;  // Commented out

int main()
{
    uint8_t phatic;
    uint8_t cmd;

    // Resume Hardware Modules (Stopped by default)
    hw_init();

    // generate_crc32_table();  // Commented out

    send((const uint8_t *) greating, sizeof(greating) - 1);

    phatic = PHATIC;
    SEND_VAR(phatic);
    //my_printf("Sent phatic value: 0x%02X\n\r", phatic);

    while(1) {
        do {
            RECV_VAR(phatic);
            //my_printf("Received phatic value: 0x%02X\n\r", phatic);
        } while(phatic != PHATIC);


        RAL.LSPA.GPIO[0]->ODR = (1 << 3);
        //my_printf("GPIO state set\n\r");

        RECV_VAR(cmd);
        //my_printf("Received command: 0x%02X\n\r", cmd);

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
    uint32_t address;
    uint16_t length;

    word_t word;
    uint8_t byte;

    // uint8_t resp;

    RECV_VAR(address);
    RECV_VAR(length);

    while(length > 0) {
        if(address % sizeof(word) == 0 && length >= sizeof(word)) {
            RECV_VAR(word);
            *(volatile word_t *)address = word;
            address += sizeof(word);
            length -= sizeof(word);
        } else {
            RECV_VAR(byte);
            *(volatile uint8_t *) address = byte;
            address += sizeof(byte);
            length -= sizeof(byte);
        }
    }

    // resp = ACK; // Always acknowledge without CRC check
    // SEND_VAR(resp);
}

void read_cmd(void)
{
    uint32_t address;
    uint16_t length;

    word_t word;
    uint8_t byte;

    // uint32_t crc_remote;  // Commented out
    // uint32_t crc_local;  // Commented out

    // uint8_t resp;

    // recv_crc = 0;  // Commented out
    RECV_VAR(address);
    //my_printf("Received address: 0x%x\n\r", address);
    RECV_VAR(length);
    //my_printf("Received length: %u\n\r", length);
    // crc_local = recv_crc;  // Commented out
    // RECV_VAR(crc_remote);  // Commented out

    // resp = (crc_local == crc_remote) ? ACK : NAK;  // Commented out
    // resp = ACK;  // Always acknowledge without CRC check
    // SEND_VAR(resp);
    //my_printf("CRC check result: %s\n\r", resp == ACK ? "ACK" : "NAK");
    // if(resp != ACK) return;  // Commented out

    while(length > 0) {
        if (address % sizeof(word) == 0 && length >= sizeof(word)) {
            // aligned word access
            word = *(volatile word_t *) (word_t) address;
            SEND_VAR(word);
            //my_printf("Sending word: 0x%X from address: 0x%x\n\r", word, address);
            address += sizeof(word);
            length -= sizeof(word);
        } else {
            // byte access
            byte = *(volatile uint8_t *) (word_t) address;
            SEND_VAR(byte);
            //my_printf("Sending byte: 0x%02X from address: 0x%08x\n\r", byte, address);
            address += sizeof(byte);
            length -= sizeof(byte);
        }
    }
    // crc_local = send_crc;  // Commented out
    // SEND_VAR(crc_local);  // Commented out
    // //my_printf("Sent CRC: 0x%08X\n\r", crc_local);  // Commented out
}

void boot_cmd(void)
{
    uint32_t address;
    // uint32_t crc_remote;  // Commented out
    // uint32_t crc_local;  // Commented out
    // uint8_t resp;

    // recv_crc = 0;  // Commented out
    RECV_VAR(address);
    //my_printf("Received boot address: 0x%08x\n\r", address);
    // crc_local = recv_crc;  // Commented out
    // RECV_VAR(crc_remote);  // Commented out

    // resp = (crc_local == crc_remote) ? ACK : NAK;  // Commented out
    // resp = ACK;  // Always acknowledge without CRC check
    // SEND_VAR(resp);
    //my_printf("CRC check result: %s\n\r", resp == ACK ? "ACK" : "NAK");
    // if(resp != ACK) return;  // Commented out

    // while(!(RAL.LSPA.UART[0]->SR & (1 << 7)));
    //my_printf("Jumping to address: 0x%08x\n\r", address);
    asm volatile ("jalr %0" : : "r"((uint32_t) address));
}

void default_cmd(void)
{
    // uint8_t resp = NAK;
    // SEND_VAR(resp);
    //my_printf("Invalid command received. Sending NAK.\n\r");
}


void send(const uint8_t *data, uint16_t len)
{
    for (uint16_t i = 0; i < len; i++) {
        while (!RAL.LSPA.UART[0]->TBE);
        RAL.LSPA.UART[0]->DR = data[i];
    }
    // send_crc = crc32(data, 1, send_crc);  // Commented out
}

void recv(uint8_t *data, uint16_t len)
{
    for (uint16_t i = 0; i < len; i++) {
        while (!RAL.LSPA.UART[0]->RBF);
        data[i] = RAL.LSPA.UART[0]->DR;
        //my_printf("Received byte: 0x%02X\n\r", data[i]);
    }
    // recv_crc = crc32(data, 1, recv_crc);  // Commented out
}

void hw_init(void) {
    // Resume UART0
    RAL.SYSCFG->LSPA.UART[0].MR = 1;
    while (RAL.SYSCFG->LSPA.UART[0].MR);

    // Resume GPIO0
    RAL.SYSCFG->LSPA.GPIO[0].MR = 1;
    while (RAL.SYSCFG->LSPA.GPIO[0].MR);

    // Enable CPU Interrupt
    RAL.SYSCFG->CPU[0].IER = ~0;

    // Init UART
    RAL.LSPA.UART[0]->BRR = SYSTEM_CLOCK / 115200; // Baud Rate
    RAL.LSPA.UART[0]->CR = (1 << 0)  // PE: Parity disabled
                         | (1 << 1)  // TE: Transmitter enabled
                         | (1 << 2)  // RE: Receiver enabled
                         | (8 << 8); // DL: 8 data bits
}
