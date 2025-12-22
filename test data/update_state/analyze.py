import json

update = dict()
create = dict()

f = open('./data/update_state.txt', 'r')
line = f.readline()
while line:
    j = json.loads(line)
    if (j['action'] == 'create'):
        create[j['slots']] = {
            'size': j['size'],
            'gasUsed': j['gasUsed']
        }
    elif (j['action'] == 'update'):
        update[j['slots']] = {
            'size': j['size'],
            'gasUsed': j['gasUsed']
        }
    line = f.readline()
f.close()



print('--------------------------------------------')
for key, value in create.items():
    print('base slots %s:' %key)
    print('create: %s (gas)' %value['gasUsed'])
    print('update: %s (gas)' %update[key]['gasUsed'])
    print('*******************************')
