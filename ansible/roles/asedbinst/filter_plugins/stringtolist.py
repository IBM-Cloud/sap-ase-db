#!/usr/bin/python

class FilterModule(object):
    '''Split a string'''

    def filters(self):
        return {
            'stringtolist': self.stringtolist
        }

    def stringtolist(self, data_string_details):
        data_string = data_string_details[0]
        separator_string = data_string_details[1]
        list_from_string = data_string.split(separator_string) 
        return list_from_string
