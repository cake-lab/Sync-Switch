#### 1-1-1-test3 

stopped at 1000 step with 1024 batch size, resumed with 128 batch size

Learning rate scaled to batch size (otherwise it occurs nanloss error): 0.8->0.1

Loss at 1000: 0.059929226

#### 1-1-1-test4

stopped at 1000 step with 1024 batch size, resumed with 256 batch size

Learning rate scaled to batch size: 0.8->0.2

Loss at 1000: 0.07092889, after resume 0.059591778

#### 1-1-1-test5

stopped at 1000 step with 1024 batch size, resumed with 512 batch size

Learning rate scaled to batch size: 0.8->0.4 

Loss at 1000: 0.06742817, after resume 0.07185458

#### 1-1-1-test6

2000 steps 1024 batch size baseline

#### 1-1-1-test7

stopped at 1000 step with 1024 batch size, resumed with 128 batch size

Learning rate not scaled

Loss at 1000: 0.07xx?

#### 1-1-1-test8

stopped at 1000 step with 1024 batch size, resumed with 128 batch size

Learning rate not scaled

Loss at 1000: 0.09891727

#### 1-1-1-test9

stopped at 1000 step with 1024 batch size, resumed with 128 batch size

Learning rate scaled to batch size: 0.8->0.1

Loss at 1000: 0.04622668

#### 1-1-1-test10

stopped at 1000 step with 1024 batch size, resumed with 128 batch size

Learning rate scaled to batch size: 0.8->0.2

Loss at 1000: 0.066745184, after resume 

#### 1-1-1-test11

stopped at 1000 step with 1024 batch size, resumed with 128 batch size

Learning rate scaled to batch size: 0.8->0.4

Loss at 1000: 0.059375435, after resume 

#### 1-1-1-test12

stopped at 1000 step with 1024 batch size, resumed with 512 batch size

Learning rate not scaled

Loss at 1000: 0.07665202, after resume 

#### 1-1-1-test13

stopped at 1000 step with 1024 batch size, resumed with 256 batch size

Learning rate not scaled

Loss at 1000: 0.048246045, after resume 0.093356535

#### 1-1-1-test14

stopped at 8000 step with 128 batch size, resumed with ASP

Learning rate not scaled

Loss at 8000: 0.053626664, after resume 

#### adam

Using 10% split and Adam optimizer with default beta1, beta2 and epsilon

#### vanilla sgd

BSP stopped at 16:36:00, loss 0.825279; eval at 16:36:21
ASP resumed at 16:39:04, final loss 0.03575377, step 58413

#### vanilla sgd run2

BSP stopped at 17:30:37, loss 1.2732309; eval at 17:30:56
ASP resumed at 17:34:16(09), final loss 0.32655418, step 58413

#### zero momentum after restore

BSP stopped at 19:25:09, loss 0.13760018; eval at 19:25:47
ASP resumed at 19:28:10, final loss 0.0017853226, step 58414

#### zero momentum after restore run2

BSP stopped at 20:19:49, loss 0.09084384; eval at 20:20:42
ASP resumed at 20:57:46, final loss 0.0010389617, step 58413

#### Scaled momentum after restore

BSP stopped at 23:11:51, loss 0.103514686; eval at 23:12:18
ASP resumed at 00:01:00, final loss 0.00164046668, step 58413

#### Scaled momentum after restore run2

BSP stopped at 01:16:35, loss 0.06222777; eval at 01:17:22
ASP resumed at 01:18:29, final loss 0.0005142937, step 58413

#### Ramped momentum after restore

BSP stopped at 02:05:47, loss 0.0854292; eval at 02:06:30
ASP with scaled momentum resumed at 02:08:17, stopped at 02:10:07, loss 0.023153666, step 4813
ASP with full momentum resumed at 02:15:04, final loss 0.0006427552, step 58411

#### Multi-step (.9/8->.9/4->.9/2->.9) ramped momentum run1

6400 step increment ((26400 - 800) / 4): 7200, 13600, 20000, 26400(actually to the end)

BSP stopped at 16:52:55, loss 0.090990245, step 800; eval at 16:53:22
Stage 1 ASP resumed at 16:58:43, stopped at 17:01:36, loss 0.010384532, step 7213
Stage 2 ASP resumed at 17:05:12, stopped at 17:08:15, loss 0.007862858(average is bigger than this), step 13614
Stage 3 ASP resumed at 17:12:06, stopped at 17:15:08, loss 0.10942196, step 20013
Stage 4 ASP resumed at 17:19:39

#### additive ramped momentum run1

1/8 -> 2/8 -> 3/8 -> 4/8 -> 5/8 -> 6/8 -> 7/8 -> 8/8

Each stage lasts for 2000 steps

workers started simutaneously

BSP stopped at 19:24:30, loss 0.21373102, step 800; eval at 19:25:12
ASP stage 1 resumed at 19:40:00, stopped at 19:41:23, loss 0.13024959, step 2814
ASP stage 2 resumed at 19:47:55, stopped at 19:48:51, loss 0.09663153, step 4812
ASP stage 3 resumed at 19:51:24, stopped at 19:52:16, loss 0.086845085, step 6814
ASP stage 4 resumed at 19:54:26, stopped at 19:55:20, loss 0.11235844, step 8814
ASP stage 5 resumed at 19:57:21, stopped at 19:58:18, loss 0.14432444, step 10851/10814
ASP stage 6 resumed at 20:00:12, stopped at 20:01:02, loss 0.18821594, step 12808
ASP stage 7 resumed at 20:03:13, stopped at 20:04:04, loss 0.24015525, step 14812
ASP stage 8 resumed at 20:05:57, stopped at 20:23:44, final loss 0.00463759, step 58404