import json
import sys
import subprocess
from sys import stderr

#utilize tenderly api (traceTransaction) to get the stateChanges of ERC20 contract caused by 50 transfer transactions
response = subprocess.run(['curl', '-X', 'POST', 'https://sepolia.gateway.tenderly.co/36R5yowMC7Hzyne7ykv9zc', '-H', 'Content-Type: application/json', '-d', '{"jsonrpc": "2.0","id": 0,"method": "tenderly_traceTransaction","params": ["0x2329f65bd36299b3c6f42a1da89907f3ce538611f02479253c8385305354f18e"]}'], stdout=subprocess.PIPE,
                        stderr=subprocess.DEVNULL).stdout
json_response = json.loads(response)

transfer_tx_num = 50
state_changes = json_response['result']['stateChanges']
for i in state_changes:
    #traverse state_changes, find the slot changes belonging to ERC20 contract (contract address: 0xadd2...bdf5)
    if i['address'] == '0xadd2607935a12814af72c06e4e5bb64a435abdf5':
        print("The changed slot number of ERC20 contract is",len(i['storage'])*transfer_tx_num)
        break





#utilize tenderly api (traceTransaction) to get the stateChanges of auction contract caused by createAuction transaction
response = subprocess.run(['curl', '-X', 'POST', 'https://sepolia.gateway.tenderly.co/36R5yowMC7Hzyne7ykv9zc', '-H', 'Content-Type: application/json', '-d', '{"jsonrpc": "2.0","id": 0,"method": "tenderly_traceTransaction","params": ["0x19e12fa01169208ce6eb133cb6ce692c41060933ee89628e7cf1a854cbb31193"]}'], stdout=subprocess.PIPE,
                        stderr=subprocess.DEVNULL).stdout
json_response = json.loads(response)

state_changes = json_response['result']['stateChanges']
for i in state_changes:
    #traverse state_changes, find the slot changes belonging to auction contract (contract address: 0x5866...aFb2)
    if i['address'] == '0x586660035bf89175c3b714bb64284635d417afb2':              
        createAuction_slots_num = len(i['storage'])
        break

#utilize tenderly api (traceTransaction) to get the stateChanges of auction contract caused by bid transaction
response = subprocess.run(['curl', '-X', 'POST', 'https://sepolia.gateway.tenderly.co/36R5yowMC7Hzyne7ykv9zc', '-H', 'Content-Type: application/json', '-d', '{"jsonrpc": "2.0","id": 0,"method": "tenderly_traceTransaction","params": ["0x9e24dbb445e8abeabc4ad2edb97782fbd78e3f2ec8140d29036da82038f0d075"]}'], stdout=subprocess.PIPE,
                        stderr=subprocess.DEVNULL).stdout
json_response = json.loads(response)

state_changes = json_response['result']['stateChanges']
for i in state_changes:
    #traverse state_changes, find the slot changes belonging to auction contract (contract address: 0x5866...aFb2)
    if i['address'] == '0x586660035bf89175c3b714bb64284635d417afb2':              
        bid_slots_num = len(i['storage'])
        break

print("The changed slot number of auction contract is",bid_slots_num + createAuction_slots_num)


#utilize tenderly api (traceTransaction) to get the stateChanges of member contract caused by createMember1 transaction
response = subprocess.run(['curl', '-X', 'POST', 'https://sepolia.gateway.tenderly.co/36R5yowMC7Hzyne7ykv9zc', '-H', 'Content-Type: application/json', '-d', '{"jsonrpc": "2.0","id": 0,"method": "tenderly_traceTransaction","params": ["0x0ead6b471d40dff4454dd7d0e1f9a67eee8756ae2d652cfe61db48693a61c4e5"]}'], stdout=subprocess.PIPE,
                        stderr=subprocess.DEVNULL).stdout
json_response = json.loads(response)

state_changes = json_response['result']['stateChanges']
for i in state_changes:
    #traverse state_changes, find the slot changes belonging to member contract (contract address: 0x424d...f4a3)
    if i['address'] == '0x424d1c0b4134bfe5e71632ba5f72beb17246f4a3':              
        j1 = i['storage']
        member_slots_num = len(j1)
        break

#utilize tenderly api (traceTransaction) to get the stateChanges of member contract caused by createMember2 transaction
response = subprocess.run(['curl', '-X', 'POST', 'https://sepolia.gateway.tenderly.co/36R5yowMC7Hzyne7ykv9zc', '-H', 'Content-Type: application/json', '-d', '{"jsonrpc": "2.0","id": 0,"method": "tenderly_traceTransaction","params": ["0x897fb2ebcc599673d00dabf765c5b7b4cb5edf012705690e6ff4ed123f9a9251"]}'], stdout=subprocess.PIPE,
                        stderr=subprocess.DEVNULL).stdout
json_response = json.loads(response)

state_changes_2 = json_response['result']['stateChanges']
for i in state_changes_2:
    #traverse state_changes_2, find the slot changes belonging to member contract (contract address: 0x424d...f4a3)
    if i['address'] == '0x424d1c0b4134bfe5e71632ba5f72beb17246f4a3':              
        j2 = i['storage']
        break

#calculate the number of slots that will be updated repeatedly in each createMember transaction
repeat_update_slots_num = 0
for i in j2:
    for j in j1:
        if i['slot'] == j['slot']:
            repeat_update_slots_num += 1
            break

create_member_tx_num = 10

print("The changed slot number of member contract is",create_member_tx_num*(member_slots_num - repeat_update_slots_num) + repeat_update_slots_num)





