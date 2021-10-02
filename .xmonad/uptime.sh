#!/bin/env bash
echo `uptime | cut -d: -f1 | cut -c2-`h
