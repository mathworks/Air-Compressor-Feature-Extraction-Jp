# 音の異音判定で活用できる6種類＋αの特徴抽出


The license is available in the License file in this repository




こちらのデモでは、1つの健全な状態と7つの異なる異常の状態を有するコンプレッサーの異音判定のアルゴリズムを示しています。




音声データはいずれも16 kHzで取得されており[1]、以下よりダウンロードできます。




[https://www.mathworks.com/supportfiles/audio/AirCompressorDataset/AirCompressorDataset.zip](https://www.mathworks.com/supportfiles/audio/AirCompressorDataset/AirCompressorDataset.zip)




下記の動画ではここで取り上げられてる6種類の特徴抽出に関して解説を行っています。




[https://www.youtube.com/watch?v=CaF7d_V2JHQ](https://www.youtube.com/watch?v=CaF7d_V2JHQ)




全てのスクリプトを実行するのに必要な製品一覧：



   1.  MATLAB® 
   1.  Signal Processing Toolbox™ 
   1.  Statistics and Machine Learning Toolbox™ 
   1.  System Identification Toolbox™ 
   1.  Predictive Maintenance Toolbox™ 
   1.  Deep Learning Toolbox™ 
   1.  DSP System Toolbox™ 
   1.  Audio Toolbox™ 
   1.  Wavelet Toolbox™ 
   1.  Image Processng Toolbox™ 



[1] N. K. Verma *et al.*, "[Intelligent Condition Based Monitoring Using Acoustic Signals for Air Compressors](https://ieeexplore.ieee.org/document/7177138)," in IEEE Transactions on Reliability, Vol.65, No.1, pp.291-309, March 2016.


# １．診断特徴デザイナー＋機械学習


method01_diagnosticFeatureDesignerML.mlx




診断特徴デザイナー（Predictive Maintenance Toolbox™）を活用した特徴抽出を行い、抽出した時間域と周波数域の特徴量を機械学習に手渡し、モデルを構築します。


# ２．スペクトログラム＋深層学習（DCNN）


method02_spectrogramDCNN.mlx




信号アナライザー（Signal Processing Toolbox™）を活用してスペクトログラムを作成し、「画像」としてディープネットに学習させます。


# ３．スカログラム＋深層学習（DCNN）


method03_scalogramDCNN.mlx




信号アナライザー（Signal Processing Toolbox™）を活用してスカログラムを作成し、「画像」としてディープネットに学習させます。


# ４・音の特徴量+深層学習（LSTM）


method04_audioFeatureExtractorLSTM.mlx




audioFeatureExtractor（Audio Toolbox™）を活用し、ケプストラム係数とその時間変動情報のデルタパラメーターを抽出します。




抽出した特徴量をLSTMに手渡し、モデルを学習させます。


# ５．バーク周波数スペクトラム＋転移学習（YAMNet）


method05_barkSpectrumYAMNet.mlx




audioFeatureExtractor（Audio Toolbox™）によりバーク周波数スペクトラムを生成し、音の分類を得意とする畳み込みニューラルネットワークYAMNetで転移学習させます。


# ６．Wavelet散乱変換＋深層学習（LSTM）


method06_waveletScatteringLSTM.mlx




Wavelet散乱変換（Wavelet Toolbox™）により抽出した特徴量をLSTMに学習させます。


# ７．yamnetPreprocess＋転移学習（YAMNet）


method07_yamnetPreprocessYAMNet.mlx




YAMNet専用の前処理yamnetPreprocess（Audio Toolbox™）により抽出した特徴量を、音の分類を得意とする畳み込みニューラルネットワークYAMNetで転移学習させます。


# ８．音の特徴量＋機械学習


dr_airCompressor_audioFeatureExtractorML.mlx




audioFeatureExtractor（Audio Toolbox™）により抽出したケプストラム係数およびスペクトル特徴量に対して、分類学習器を用いて機械学習させます。


# ９．Wavelet散乱変換＋SVM


dr_airCompressor_waveletScatteringSVM.mlx




Wavelet散乱変換（Wavelet Toolbox™）により抽出した特徴量をSVMに学習させます。




*Copyright 2021 The MathWorks, Inc.*


