function [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
% [trainedClassifier, validationAccuracy] = trainClassifier(trainingData)
% 学習済み分類器とその 精度 を返します。このコードは分類学習器アプリで学習させた分類モデル
% を再作成します。生成されるコードを使用して、同じモデルでの新規データを使用した学習の自動化
% や、プログラミングによってモデルに学習させる方法の調査を行います。
%
%  入力:
%      trainingData: アプリにインポートされたものと同じ予測子列と応答列を含むテーブル。
%
%  出力:
%      trainedClassifier: 学習済みの分類器を含む struct。この struct には、学習済み
%       の分類器に関する情報をもつさまざまなフィールドが含まれています。
%
%      trainedClassifier.predictFcn: 新規データに関する予測を行う関数。
%
%      validationAccuracy: パーセント単位の精度を表す double。アプリでは [履歴] リ
%       ストにこの全体的な精度スコアがモデルごとに表示されます。
%
% このコードを使用して新規データでモデルに学習させます。分類器に再学習させるには、元のデータ
% または新規データを入力引数 trainingData として指定して、コマンド ラインから関数を呼び
% 出します。
%
% たとえば、元のデータセット T で学習させた分類器に再学習させるには、次を入力します:
%   [trainedClassifier, validationAccuracy] = trainClassifier(T)
%
% 返された 'trainedClassifier' を使用して新規データ T2 の予測を行うには、次を使用しま
% す
%   yfit = trainedClassifier.predictFcn(T2)
%
% T2 は、少なくとも学習中に使用したものと同じ予測列を含むテーブルでなければなりません。詳細
% については、次のように入力してください:
%   trainedClassifier.HowToPredict

% MATLAB からの自動生成日: 2021/05/25 00:45:35


% 予測子と応答の抽出
% このコードは、データを処理して、モデルに学習させるのに適した
% 形状にします。
inputTable = trainingData;
predictorNames = {'data_stats/ClearanceFactor', 'data_stats/CrestFactor', 'data_stats/ImpulseFactor', 'data_stats/Kurtosis', 'data_stats/Mean', 'data_stats/PeakValue', 'data_stats/RMS', 'data_stats/SINAD', 'data_stats/SNR', 'data_stats/ShapeFactor', 'data_stats/Skewness', 'data_stats/Std', 'data_stats/THD', 'data_ps_spec/PeakAmp1', 'data_ps_spec/PeakAmp2', 'data_ps_spec/PeakFreq1', 'data_ps_spec/PeakFreq2', 'data_ps_spec/BandPower'};
predictors = inputTable(:, predictorNames);
response = inputTable.faultCode;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% 分類器の学習
% このコードは、すべての分類器オプションを指定し、分類器に学習させます。
template = templateTree(...
    'MaxNumSplits', 1263);
classificationEnsemble = fitcensemble(...
    predictors, ...
    response, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 30, ...
    'Learners', template, ...
    'ClassNames', categorical({'Bearing'; 'Flywheel'; 'Healthy'; 'LIV'; 'LOV'; 'NRV'; 'Piston'; 'Riderbelt'}));

% 関数 predict で結果の構造体を作成
predictorExtractionFcn = @(t) t(:, predictorNames);
ensemblePredictFcn = @(x) predict(classificationEnsemble, x);
trainedClassifier.predictFcn = @(x) ensemblePredictFcn(predictorExtractionFcn(x));

% 結果の構造体にさらにフィールドを追加
trainedClassifier.RequiredVariables = {'data_ps_spec/BandPower', 'data_ps_spec/PeakAmp1', 'data_ps_spec/PeakAmp2', 'data_ps_spec/PeakFreq1', 'data_ps_spec/PeakFreq2', 'data_stats/ClearanceFactor', 'data_stats/CrestFactor', 'data_stats/ImpulseFactor', 'data_stats/Kurtosis', 'data_stats/Mean', 'data_stats/PeakValue', 'data_stats/RMS', 'data_stats/SINAD', 'data_stats/SNR', 'data_stats/ShapeFactor', 'data_stats/Skewness', 'data_stats/Std', 'data_stats/THD'};
trainedClassifier.ClassificationEnsemble = classificationEnsemble;
trainedClassifier.About = 'この構造体は、分類学習器 R2021a からエクスポートされた学習済みのモデルです。';
trainedClassifier.HowToPredict = sprintf('新しいテーブル T についての予測を行うには、次を使用します: \n yfit = c.predictFcn(T) \n''c'' をこの構造体の変数の名前 (''trainedModel'' など) に置き換えます。 \n \nテーブル T は次によって返される変数を含んでいなければなりません: \n c.RequiredVariables \n変数形式 (行列/ベクトル、データ型など) は元の学習データと一致しなければなりません。 \n追加の変数は無視されます。 \n \n詳細については、<a href="matlab:helpview(fullfile(docroot, ''stats'', ''stats.map''), ''appclassification_exportmodeltoworkspace'')">How to predict using an exported model</a> を参照してください。');

% 予測子と応答の抽出
% このコードは、データを処理して、モデルに学習させるのに適した
% 形状にします。
inputTable = trainingData;
predictorNames = {'data_stats/ClearanceFactor', 'data_stats/CrestFactor', 'data_stats/ImpulseFactor', 'data_stats/Kurtosis', 'data_stats/Mean', 'data_stats/PeakValue', 'data_stats/RMS', 'data_stats/SINAD', 'data_stats/SNR', 'data_stats/ShapeFactor', 'data_stats/Skewness', 'data_stats/Std', 'data_stats/THD', 'data_ps_spec/PeakAmp1', 'data_ps_spec/PeakAmp2', 'data_ps_spec/PeakFreq1', 'data_ps_spec/PeakFreq2', 'data_ps_spec/BandPower'};
predictors = inputTable(:, predictorNames);
response = inputTable.faultCode;
isCategoricalPredictor = [false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false];

% 交差検証の実行
partitionedModel = crossval(trainedClassifier.ClassificationEnsemble, 'KFold', 5);

% 検証予測の計算
[validationPredictions, validationScores] = kfoldPredict(partitionedModel);

% 検証精度の計算
validationAccuracy = 1 - kfoldLoss(partitionedModel, 'LossFun', 'ClassifError');

% Copyright 2021 The MathWorks, Inc.