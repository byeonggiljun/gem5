#!/usr/bin/env python3

# Copyright (c) 2026
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer;
# redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution;
# neither the name of the copyright holders nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

"""
Minimal syscall-emulation gem5 configuration using Ramulator2 as the memory
controller.

This follows the integration pattern described in
`ext/ramulator2/README.md`, section
"Using Ramulator 2.0 as a Library (gem5 Example)".
"""

import argparse
import os
import re

import m5
from m5.objects import *


def default_binary():
    this_dir = os.path.dirname(os.path.realpath(__file__))
    return os.path.join(
        this_dir,
        "..",
        "..",
        "tests",
        "test-progs",
        "hello",
        "bin",
        "x86",
        "linux",
        "hello",
    )


def has_gem5_frontend(config_path):
    with open(config_path, "r", encoding="utf-8") as config_file:
        config_text = config_file.read()

    return re.search(
        r"Frontend:\s*(?:#.*\n|\s*\n|[ \t].*\n)*[ \t]*impl:\s*GEM5\b",
        config_text,
        re.MULTILINE,
    )


parser = argparse.ArgumentParser(
    formatter_class=argparse.ArgumentDefaultsHelpFormatter
)
parser.add_argument(
    "--ramulator-config",
    required=True,
    help="Path to a Ramulator2 YAML config whose Frontend impl is GEM5.",
)
parser.add_argument(
    "--binary",
    default=default_binary(),
    help="SE-mode workload binary to run.",
)
parser.add_argument(
    "--mem-size",
    default="512MiB",
    help="Size of the system memory range.",
)
parser.add_argument(
    "--clock",
    default="1GHz",
    help="Top-level system clock.",
)
args = parser.parse_args()

ramulator_config = os.path.abspath(args.ramulator_config)
binary = os.path.abspath(args.binary)

if not os.path.exists(ramulator_config):
    raise FileNotFoundError(
        f"Ramulator2 config file not found: {ramulator_config}"
    )

if not os.path.exists(binary):
    raise FileNotFoundError(f"Workload binary not found: {binary}")

if "Ramulator2" not in globals():
    raise RuntimeError(
        "Ramulator2 SimObject is unavailable. Rebuild gem5 with the "
        "Ramulator2 wrapper enabled first."
    )

if not has_gem5_frontend(ramulator_config):
    raise RuntimeError(
        "The Ramulator2 config does not appear to set 'Frontend: impl: GEM5'."
    )

system = System()

system.clk_domain = SrcClockDomain()
system.clk_domain.clock = args.clock
system.clk_domain.voltage_domain = VoltageDomain()

system.mem_mode = "timing"
system.mem_ranges = [AddrRange(args.mem_size)]

system.cpu = X86TimingSimpleCPU()
system.membus = SystemXBar()

system.cpu.icache_port = system.membus.cpu_side_ports
system.cpu.dcache_port = system.membus.cpu_side_ports

system.cpu.createInterruptController()
system.cpu.interrupts[0].pio = system.membus.mem_side_ports
system.cpu.interrupts[0].int_requestor = system.membus.cpu_side_ports
system.cpu.interrupts[0].int_responder = system.membus.mem_side_ports

system.mem_ctrl = Ramulator2()
system.mem_ctrl.range = system.mem_ranges[0]
system.mem_ctrl.config_path = ramulator_config
system.mem_ctrl.port = system.membus.mem_side_ports

system.system_port = system.membus.cpu_side_ports
system.workload = SEWorkload.init_compatible(binary)

process = Process()
process.cmd = [binary]
system.cpu.workload = process
system.cpu.createThreads()

root = Root(full_system=False, system=system)
m5.instantiate()

print("Beginning simulation with Ramulator2 memory controller")
print(f"  binary: {binary}")
print(f"  ramulator_config: {ramulator_config}")
exit_event = m5.simulate()
print(f"Exiting @ tick {m5.curTick()} because {exit_event.getCause()}")
