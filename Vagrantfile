# -*- mode: ruby -*-
# vi: set ft=ruby :

###############################################################################
# Kubernetes vagrant provisioning                                             #
#                                                                             #
# @author     :-  batpool                                                     #
#                                                                             #
# LICENSE                                                                     #
#                                                                             #
# Copyright (c) 2012 "copyright notice checker" Authors. All rights reserved. #
#                                                                             #
# Redistribution and use in source and binary forms, with or without          #
# modification, are permitted provided that the following conditions are      #
# met:                                                                        #
#                                                                             #
# * Redistributions of source code must retain the above copyright            #
# notice, this list of conditions and the following disclaimer.               #
#                                                                             #
# * Redistributions in binary form must reproduce the above                   #
# copyright notice, this list of conditions and the following disclaimer      #
# in the documentation and/or other materials provided with the               #
# distribution.                                                               #
#                                                                             #
# * None of the names of its contributors may be used to endorse              #
# or promote products derived from this software without specific             #
# prior written permission.                                                   #
#                                                                             #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS         #
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT           #
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR       #
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT        #
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,       #
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT            #
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,       #
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY       #
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT         #
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE       #
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.        #
###############################################################################


ENV['VAGRANT_NO_PARALLEL'] = 'yes'

Vagrant.configure(2) do |config|

  config.vm.provision "shell", path: "bootstrap.sh"

  # Kubernetes Master Server
  config.vm.define "kmaster" do |node|
  
    node.vm.box               = "generic/ubuntu2004"
    node.vm.box_check_update  = false
    node.vm.hostname          = "kmaster.batpool.com"

    node.vm.network "private_network", ip: "192.168.58.100"
  
    node.vm.provider :virtualbox do |v|
      v.name    = "kmaster"
      v.memory  = 2048
      v.cpus    =  2
    end
  
    node.vm.provision "shell", path: "bootstrap_kmaster.sh"
  
  end


  # Kubernetes Worker Nodes
  NodeCount = 2

  (1..NodeCount).each do |i|

    config.vm.define "kworker#{i}" do |node|

      node.vm.box               = "generic/ubuntu2004"
      node.vm.box_check_update  = false
      node.vm.hostname          = "kworker#{i}.batpool.com"

      node.vm.network "private_network", ip: "192.168.58.10#{i}"

      node.vm.provider :virtualbox do |v|
        v.name    = "kworker#{i}"
        v.memory  = 1024
        v.cpus    = 1
      end

      node.vm.provision "shell", path: "bootstrap_kworker.sh"

    end

  end

end
