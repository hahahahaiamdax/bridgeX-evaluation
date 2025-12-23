import json

tx = dict()
baseline = dict()
logic = dict()
proxy = dict()
upgradeTo = dict()
escrow = dict()
transfer_min = dict()
transfer_max = dict()

f = open('./data/data.txt', 'r')
line = f.readline()
while line:
    j = json.loads(line)
    if (j['name'] == 'Deploy'):
        if (j['method'] == 'CloakService'):
            cloakService = {
                'size': j['size'],
                'gasUsed': j['gasUsed']
            }
    if (j['name'] == 'send'):
        if (j['method'] == 'logic'):
            logic[j["baseline"]] = {
                'size': j['size'],
                'gasUsed': j['gasUsed']
            }
        elif (j['method'] == 'proxy'):
            proxy[j["baseline"]] = {
                'size': j['size'],
                'gasUsed': j['gasUsed']
            }
        elif j['method'] == 'upgradeTo':
            upgradeTo[j["baseline"]] = {
                'size': j['size'],
                'gasUsed': j['gasUsed']
            }

        elif j['method'] == 'escrow':
            escrow[j["baseline"]] = {
                'size': j['size'],
                'gasUsed': j['gasUsed']
            }


    if j['name'] == 'cloak':
        if j['method'] == 'transfer':
            if j["baseline"] in transfer_max:
                transfer_min[j["baseline"]].append(j['startTime'])
                transfer_max[j["baseline"]].append(j['finishTime'])
            else:
                transfer_min[j["baseline"]] = [j['startTime']]
                transfer_max[j["baseline"]] = [j['finishTime']]

    line = f.readline()
f.close()

f = open('./data/txs.txt', 'r')
line = f.readline()
transaction = []
transaction_id = []
while line:
    j = json.loads(line)
    end_time = int(j["time"]["end_time"])
    start_time = int(j["time"]["start_time"])
    delay = end_time * 1000 - start_time
    transaction.append({
        "gasUsed": j["gasUsed"],
        "timer": delay
    })
    transaction_id.append(j['id'])
    line = f.readline()
f.close()

f = open('./data/unescrow.txt')
line = f.readline()
transaction_unescrow = dict()
while line:
    j = json.loads(line)
    transaction_unescrow[j['id']] = {
        'address': j['address'].lower(),
        'gasUsed': j['gasUsed']
    }
    line = f.readline()
f.close()

f = open('./data/state.txt')
line = f.readline()
escrow_start_time = dict()
escrow_end_time = dict()
states = dict()
while line:
    j = json.loads(line)
    if j['name'] == 'escrow':
        msg = j["args"]
        if "start_time" in msg:
            escrow_start_time[msg['contract'].lower()] = int(msg['start_time'])
        elif 'end_time' in msg:
            escrow_end_time[msg['contract'].lower()] = int(msg['end_time'])

    elif j['name'] == 'state':
        msg = j['args']
        address = msg['address'].lower()
        start_time = int(msg['start_time'])
        end_time = int(msg['end_time'])
        
        if address in states:
            states[address].append(end_time - start_time)
        else:
            states[address] = [end_time-start_time]

    line = f.readline()
f.close()


print('deploy cloak service: %s (gas)' %cloakService['gasUsed'])
print('--------------------------------------------')
i = 0
for key, value in logic.items():
    print('baseline %s:' %key)
    id = transaction_id[i]
    unescrow = transaction_unescrow[id]
    print('deploy logic contract: %s (gas)' %value['gasUsed'])
    print('deploy proxy contract: %s (gas)' %proxy[key]['gasUsed'])
    print('upgrade to bridge transaction: %s (gas)' %upgradeTo[key]['gasUsed'])
    print('escrow transaction: %s (gas)' %escrow[key]['gasUsed'])
    delay = escrow_end_time[unescrow['address']] - escrow_start_time[unescrow['address']]
    print('escrow contract to cloak: %d (μs)' %(delay))
    delay = max(transfer_max[key]) - min(transfer_min[key])
    print('transfer tx average response timer: %d (ms)' %(delay))
    print('update state to ethereum tx: %s (gas)' %transaction[i]['gasUsed'])
    print('time spent constructing state-sync transaction: %d (μs)'  %transaction[i]['timer'])
    print('update state and unescrow to ethereum tx: %s (gas)' %unescrow['gasUsed'])
    i +=1
    print('-------------------------------')
    print("cloak reads state from ethereum: ")
    state = states[unescrow['address']]
    print('number of read operations: %d' %len(state))
    print('average read latency: %d (μs)' %(sum(state) / len(state)))
    print('*******************************')
