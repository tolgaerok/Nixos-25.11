#!/usr/bin/env bash
# Tolga Erok
# Quick one-line NVIDIA status checker

if cat /proc/driver/nvidia/version 2>/dev/null | grep -q "Open"; then 
    echo "✓ NVIDIA Open Driver $(cat /proc/driver/nvidia/version | awk '{print $8}') - $(nvidia-smi --query-gpu=name --format=csv,noheader) @ $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)°C"
else 
    echo "⚠ NVIDIA Proprietary Driver $(cat /proc/driver/nvidia/version | awk '{print $8}') - $(nvidia-smi --query-gpu=name --format=csv,noheader) @ $(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)°C"
fi