#!/bin/bash

MAC='24:73:24:03:6C:C6'
bluetoothctl power on
bluetoothctl remove $MAC
bluetoothctl pair $MAC
bluetoothctl trust $MAC
bluetoothctl connect $MAC
