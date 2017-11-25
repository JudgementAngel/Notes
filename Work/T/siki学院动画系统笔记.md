#siki学院动画系统笔记

## 1、动画分类

###普通的

​	Animation下面的Samples属性是控制一秒多少帧的



###UGUI的按钮动画（四个状态）

####	Root Motion 设置

###人物角色的

####	人形的和非人形的（例如蜘蛛）

Generic导入的动画是无法被别人使用的

Humanoid导入的动画可以被公用，这个叫做动画重定向

Optimize Game Objects 勾选上会优化骨骼那些根节点

Generic：无法通过动画控制人物移动

Humanoid：可以通过动画来控制人物移动，这样人物会比较协调

loop match 判断第一帧和最后一帧是否吻合

Bake Into Pose 烘焙到姿势里，不再对Rotation产生影响

BasedUpon 设置动画偏移的点

## 2、普通动画创建

## 3、什么是Animator

## 4、UGUI的按钮动画

## 5、2D游戏的精灵动画

## 6、人物角色的动画导入

### 模型的两种模型动画存储方式

### 三种动画导入方式

## 7、Avatar Mask

尽量使用Animator.StringToHash("字符串")获得ID值来代替直接使用字符串

Mirror是左右对称不是前后对称



Blend Tree

2D Simple Directional 动画在多个不同的方向，在这个模式下不能有同一个方向的动画，例如不能有walk forward 和 run forward

2D Freeform Directional 动画在多个不同的方向，在这个模式下可以有同一个方向的动画，必须保证有一个动画在0，0位置

2D Freeform Cartesian 方向一致，但是头或者身体会向左右侧，不会发生转向

## 8、MatchTarget

Match Target 在动画过度的时候是不能用的

Match Target 的两个时间是开始插值的时间和最终插值到这个点位置的时间

当你的动画里有一个曲线的名字和状态机里的参数的名字一致，Animator就会通过曲线的值来修改参数的值

## 9、IK动画





