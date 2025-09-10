#!/bin/bash
echo "=== AKIKO OS Builder ==="
make clean
make
echo "=== Lancement AKIKO OS ==="
make run