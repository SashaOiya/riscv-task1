# RISC-V Fortune Teller — чтение CSR через SBI + syscall

## 📌 Задача

> * Добавить новый системный вызов в Linux kernel  
> * Добавить новый вызов SBI  
> * Напечатать в приложении значение CSR, полученного по этой цепочке из M‑Mode  
## 🎯 Решение

- Приложение вызывает системный вызов `csr_fortune(type)`
- Ядро Linux через `sbi_ecall` обращается к новому SBI‑расширению `SBI_EXT_FORTUNE`
- OpenSBI в M‑mode читает `mcycle` или `mstatus` и применяет **магические преобразования**:
  - XOR с ASCII‑константой `"RISCV-M!"`
  - циклический сдвиг влево на 13 бит  
  - XOR с `0xDEADBEEF` (для `mcycle`)
  - инверсия битов (для `mstatus`)
- Результат («пророчество») возвращается обратно в приложение

Таким образом, CSR‑значение действительно проходит путь **U‑Mode → syscall → S‑Mode → SBI → M‑Mode → обратно**.

## 🚀 Запуск

```bash
git clone https://github.com/SashaOiya/riscv-task1.git
cd riscv-task1
chmod +x scripts/*.sh
./scripts/configure.sh
./scripts/build.sh
./scripts/run_qemu.sh
