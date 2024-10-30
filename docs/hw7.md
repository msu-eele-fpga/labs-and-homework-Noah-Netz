
# Homework 7: Linux CLI Practice

## Problem 1: Count the number of words in `lorem-ipsum.txt`
```bash
wc -w lorem-ipsum.txt
```
![Problem 1 Screenshot](assets/Hw7/Hw7_Prob1.png)

---

## Problem 2: Count the number of characters in `lorem-ipsum.txt`
```bash
wc -m lorem-ipsum.txt
```
![Problem 2 Screenshot](assets/Hw7/Hw7_Prob2.png)

---

## Problem 3: Count the number of lines in `lorem-ipsum.txt`
```bash
wc -l lorem-ipsum.txt
```
![Problem 3 Screenshot](assets/Hw7/Hw7_Prob3.png)

---

## Problem 4: Numerically sort `file-sizes.txt` with unit multipliers
```bash
sort -h file-sizes.txt
```
![Problem 4 Screenshot](assets/Hw7/Hw7_Prob4.png)

---

## Problem 5: Numerically sort `file-sizes.txt` in reverse order
```bash
sort -rh file-sizes.txt
```
![Problem 5 Screenshot](assets/Hw7/Hw7_Prob5.png)

---

## Problem 6: Return the IP address column from `log.csv`
```bash
cut -d ',' -f 2 log.csv
```
![Problem 6 Screenshot](assets/Hw7/Hw7_Prob6.png)

---

## Problem 7: Return the timestamp and IP address columns from `log.csv`
```bash
cut -d ',' -f 1,2 log.csv
```
![Problem 7 Screenshot](assets/Hw7/Hw7_Prob7.png)

---

## Problem 8: Return the UUID and country columns from `log.csv`
```bash
cut -d ',' -f 3,4 log.csv
```
![Problem 8 Screenshot](assets/Hw7/Hw7_Prob8.png)

---

## Problem 9: Print the first 3 lines of `gibberish.txt`
```bash
head -n 3 gibberish.txt
```
![Problem 9 Screenshot](assets/Hw7/Hw7_Prob9.png)

---

## Problem 10: Print the last 2 lines of `gibberish.txt`
```bash
tail -n 2 gibberish.txt
```
![Problem 10 Screenshot](assets/Hw7/Hw7_Prob10.png)

---

## Problem 11: Print `log.csv` without the header
```bash
tail -n +2 log.csv
```
![Problem 11 Screenshot](assets/Hw7/Hw7_Prob11.png)

---

## Problem 12: Search for “and” in `gibberish.txt`
```bash
grep 'and' gibberish.txt
```
![Problem 12 Screenshot](assets/Hw7/Hw7_Prob12.png)

---

## Problem 13: Display occurrences of “we” with line numbers
```bash
grep -w -n 'we' gibberish.txt
```
![Problem 13 Screenshot](assets/Hw7/Hw7_Prob13.png)

---

## Problem 14: Print occurrences of “to <word>” on their own line
```bash
grep -oP '(?i)\bto \w+' gibberish.txt
```
![Problem 14 Screenshot](assets/Hw7/Hw7_Prob14.png)

---

## Problem 15: Count lines with "FPGAs" in `fpgas.txt`
```bash
grep -c 'FPGAs' fpgas.txt
```
![Problem 15 Screenshot](assets/Hw7/Hw7_Prob15.png)

---

## Problem 16: Print the rhyming lines in `fpgas.txt`
```bash
grep -E '(hot|not|cower|tower|smile|compile)' fpgas.txt
```
![Problem 16 Screenshot](assets/Hw7/Hw7_Prob16.png)

---

## Problem 17: Count comment lines in VHDL files
```bash
find ../../hdl/led-patterns -name '*.vhd' -exec sh -c 'echo -n "{}:"; grep -c "^--" "{}"' \;
```
![Problem 17 Screenshot](assets/Hw7/Hw7_Prob17.png)

---

## Problem 18: Redirect `ls` output to a file and display with `cat`
```bash
ls > ls-output.txt
cat ls-output.txt
```
![Problem 18 Screenshot](assets/Hw7/Hw7_Prob18.png)

---

## Problem 19: Search for “CPU” in `dmesg` output
```bash
sudo dmesg | grep 'CPU'
```
![Problem 19 Screenshot](assets/Hw7/Hw7_Prob19.png)

---

## Problem 20: Count VHDL files in the `hdl/` directory
```bash
find hdl/ -iname '*.vhd' | wc -l
```
![Problem 20 Screenshot](assets/Hw7/Hw7_Prob20.png)

---

## Problem 21: Count the total number of comment lines in `hdl/`
```bash
grep -r '^--' --include='*.vhd' ../../hdl/ | wc -l
```
![Problem 21 Screenshot](assets/Hw7/Hw7_Prob21.png)

---

## Problem 22: Print line numbers where "FPGAs" appear
```bash
grep -n 'FPGAs' fpgas.txt | cut -d ':' -f 1
```
![Problem 22 Screenshot](assets/Hw7/Hw7_Prob22.png)

---

## Problem 23: Find the 3 largest directories in the repository
```bash
du -h --max-depth=1 ../../ | sort -rh | head -n 3
```
![Problem 23 Screenshot](assets/Hw7/Hw7_Prob23.png)

---
