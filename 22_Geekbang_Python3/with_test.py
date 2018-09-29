class TestWith():
    def __enter__(self):
        print('enter')
        pass

    def __exit__(self, exc_type, exc_val, exc_tb):
        print('exit')

        if exc_tb is None:  # 没有异常的话 exc_tb的值就是None
            print('正常')
        else:
            print('error' + str(exc_tb))


with TestWith():
    print('Test is runing')
    raise NameError('1')
