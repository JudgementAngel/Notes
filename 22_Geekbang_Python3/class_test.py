class Monster():
    """定义怪物类"""

    def __init__(self, hp):
        self.hp = hp

    def run(self):
        print('run' + self.hp)


class Animals(Monster):
    def __init__(self, hp):
        super().__init__(hp)

    pass
