#!/usr/local/bin/python
from __future__ import print_function
import yaml
import os

def build_inventory(d):
  with open("inventory.dat", "w") as invf:
    # write an entry for localhost
    print("localhost ansible_ssh_host=127.0.0.1\n", file=invf)
    ssh_user = d["ssh_info"]["user"]
    print("[resources:children]\nmaster\nworkers\n", file=invf)
    # write out the master first
    print("[master]", file=invf)
    master = d["machines"]["master"]
    print("{} ansible_ssh_host={} ansible_user={}".format(master["name"], master["ip"], ssh_user), file=invf)
    # write out the workers next
    print("\n[workers]", file=invf)
    for worker in d["machines"]["workers"]:
      print("{} ansible_ssh_host={} ansible_user={}".format(worker["name"], worker["ip"], ssh_user), file=invf)

def configure_ssh(d):
  home_dir=os.path.expanduser('~')
  if not os.path.exists(home_dir+"/.ssh"):
    os.makedirs(home_dir+"/.ssh",0700)
  if not os.path.exists(home_dir+"/.ssh/id_rsa.pub"):
    with os.fdopen(os.open(home_dir+"/.ssh/id_rsa.pub", os.O_WRONLY | os.O_CREAT, 00644), 'w') as fp:
      print(d["ssh_info"]["public_key"], file=fp)
  if not os.path.exists(home_dir+"/.ssh/id_rsa"):
    with os.fdopen(os.open(home_dir+"/.ssh/id_rsa", os.O_WRONLY | os.O_CREAT, 00600), 'w') as fp:
      print(d["ssh_info"]["private_key"], file=fp)

if __name__ == "__main__":
  f = open("/inventory.yml")
  inv = yaml.load(f)
  build_inventory(inv)
