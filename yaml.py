#!/usr/bin/env python3

from ruamel.yaml.comments import CommentedSeq
from ruamel.yaml.representer import SafeRepresenter, RoundTripRepresenter
from ruamel.yaml import YAML
import sys

def represent_list(self, data):
    if isinstance(data, list):
        data = CommentedSeq(d for d in data)
    if isinstance(data, CommentedSeq) and len(data) > 1:
        data.fa.set_block_style()
    return RoundTripRepresenter.represent_list(self, data)

def represent_multiline_string(self, data):
    if isinstance(data, str) and '\n' in data:
        return SafeRepresenter.represent_scalar(self, u'tag:yaml.org,2002:str', data, style='|')
    if ':' in data:
        return SafeRepresenter.represent_scalar(self, u'tag:yaml.org,2002:str', data, style=r"'")
    return SafeRepresenter.represent_str(self, data)

input_ = open(sys.argv[1]) if len(sys.argv) > 1 else sys.stdin

yaml = YAML()
yaml.default_flow_style = False
yaml.indent(mapping=2, sequence=4, offset=2)
yaml.representer.add_representer(type(None), SafeRepresenter.represent_none)
yaml.representer.add_representer(str, represent_multiline_string)
yaml.representer.add_representer(CommentedSeq, represent_list)

data = yaml.load(input_)
data.fa.set_block_style()
yaml.dump(data, sys.stdout)

