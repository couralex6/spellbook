import os
import re

def main():
    for root, dirs, files in os.walk('models'):
        for file in files:
            if file.endswith('.sql'):
                # print(os.path.join(root, file))
                with open(os.path.join(root, file), 'r') as f:
                    text = f.read()
                    text = remove_quotes(text)
                with open(os.path.join(root, file), 'w') as f:
                    f.write(text)

def remove_quotes(text):
    return re.sub(r"'(0x[a-fA-F0-9]{40})'", r"\1", text)

test_string = """

SELECT
  contract_address, name, '' as symbol
FROM
  (VALUES
 ('0xb8df6cc3050cc02f967db1ee48330ba23276a492',	'OptiPunk')
,('0x52782699900df91b58ecd618e77847c5774dcd2e',	'Optimistic Bunnies')
,('0x006eb613cc586198003a119485594ecbbdf41230',	'OptimisticLoogies')
,('0x5763f564e0b5d8233da0accf2585f2dbef0f0dfa',	'OldEnglish (OE40)')
,('0xeb0d6c099b2fb18da09ad554b7612bfae6a9c9ab',	'Otter Coloring Book')
,('0xb0cd054ff1b233b366468331a898da7fd5c06988', 'OPTIBOAT')
,('0x1d46b0644f5a979de14e880d06b28094e9a43b2d', 'Myhome')
,('0x3b227fc544ec74e192631d8cffd536e854716062', 'Oppa Bear Evolution Gen.1')

) as temp_table (contract_address, name)

"""
if __name__ == '__main__':
    # print(remove_quotes(test_string))
    main()