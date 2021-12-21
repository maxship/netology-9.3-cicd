def increment(index):
    local_index =0
    local_index += 1
    local_index += index
    return local_index
def get_square(numb):
    return numb*numb
def print_numb(numb):
    print("Number is {}".format(numb))

index = 0
while (index < 10):
    index = increment(index)
    print(get_square(index))