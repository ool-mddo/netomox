from pybatfish.client.commands import *
from pybatfish.question.question import load_questions
from pybatfish.question import bfq
from pybatfish.datamodel.flow import *
from sys import argv
from os import path
from pprint import pprint

# call this script with `pthon -i` and query interactive.
if __name__ == "__main__":
    if argv[1] and path.isdir(argv[1]):
        load_questions()
        print(path.abspath(argv[1]))
        bf_init_snapshot(argv[1], name='sample', overwrite=True)
    else:
        print('Usage: python -i %s ./path/to/sample' % argv[0])

# # layer3
# ans = bfq.edges(edgeType='layer3')
# ans.answer().frame()

# # layer1
# ans = bfq.edges(edgeType='layer1')
# ans.answer().frame()

# # select edges by host name
# df = ans.answer().frame()
# df.loc[list(map(lambda d: d.hostname=='host11', df.Interface.values))]
