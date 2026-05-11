#include <stdio.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <sys/reboot.h>

#define __NR_csr_fortune 462

int main() {
    unsigned long prophecy = syscall(__NR_csr_fortune, 0);
    unsigned long mstatus_inv = syscall(__NR_csr_fortune, 1);

    printf("\n--- MIPT FRKT: RISC-V Prophecy ---\n");
    printf("🔮 Prophecy (mcycle ^ magic) : %#lx\n", prophecy);
    printf("⚡ Inverted mstatus (via SBI) : %#lx\n", mstatus_inv);
    printf("------------------------------------\n");
    reboot(RB_POWER_OFF);
    return 0;
}

