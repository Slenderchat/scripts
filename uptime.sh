#!/bin/bash
parallel -j 0 "echo {1}: ; ssh -4akTx root@192.168.{2} uptime" ::: danilevskii-4 danilevskii-3 danilevskii-2 danilevskii-1 sverdlova-2 sverdlova-1 spb-1 :::+ 1.4 1.3 1.2 1.1 0.2 0.1 2.1
