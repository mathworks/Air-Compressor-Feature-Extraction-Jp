function [featureTable,ranking,outputTable] = diagnosticFeatures(inputData)
%DIAGNOSTICFEATURES recreates results in Diagnostic Feature Designer.
%
% Input:
%  inputData: A table or a cell array of tables/matrices containing the
%  data as those imported into the app.
%
% Output:
%  featureTable: A table containing all features and condition variables.
%  ranking: A table containing ranking scores for selected features.
%  outputTable: A table containing the computation results.
%
% This function computes spectra:
%  data_ps/SpectrumData
%
% This function computes features:
%  data_stats/ClearanceFactor
%  data_stats/CrestFactor
%  data_stats/ImpulseFactor
%  data_stats/Kurtosis
%  data_stats/Mean
%  data_stats/PeakValue
%  data_stats/RMS
%  data_stats/SINAD
%  data_stats/SNR
%  data_stats/ShapeFactor
%  data_stats/Skewness
%  data_stats/Std
%  data_stats/THD
%  data_ps_spec/PeakAmp1
%  data_ps_spec/PeakAmp2
%  data_ps_spec/PeakFreq1
%  data_ps_spec/PeakFreq2
%  data_ps_spec/BandPower
%
% This function ranks computed feautres using algorithms:
%  One-way ANOVA
%
% Organization of the function:
% 1. Compute signals/spectra/features
% 2. Extract computed features into a table
% 3. Rank features
%
% Modify the function to add or remove data processing, feature generation
% or ranking operations.

% Auto-generated by MATLAB on 2021/05/24 13:43:56

% 出力アンサンブルを作成します。
outputEnsemble = workspaceEnsemble(inputData,'DataVariables',"data",'ConditionVariables',"faultCode");

% アンサンブルの先頭から読み取るようにアンサンブルをリセットします。
reset(outputEnsemble);

% 新しい信号名または特徴名を DataVariables に追加します。
outputEnsemble.DataVariables = unique([outputEnsemble.DataVariables;"data_stats";"data_ps";"data_ps_spec"],'stable');

% SelectedVariables を設定して、アンサンブルから読み取る変数を選択します。
outputEnsemble.SelectedVariables = "data";

% すべてのアンサンブル メンバーをループ処理して、データの読み取りと書き込みを行います。
while hasdata(outputEnsemble)
    % 1 つのメンバーを読み取ります。
    member = read(outputEnsemble);
    
    % すべての入力変数を取得します。
    data = readMemberData(member,"data",["Time","audioIn"]);
    
    % table を初期化して結果を保存します。
    memberResult = table;
    
    %% SignalFeatures
    try
        % 信号特徴を計算します。
        inputSignal = data.audioIn;
        ClearanceFactor = max(abs(inputSignal))/(mean(sqrt(abs(inputSignal)))^2);
        CrestFactor = peak2rms(inputSignal);
        ImpulseFactor = max(abs(inputSignal))/mean(abs(inputSignal));
        Kurtosis = kurtosis(inputSignal);
        Mean = mean(inputSignal,'omitnan');
        PeakValue = max(abs(inputSignal));
        RMS = rms(inputSignal,'omitnan');
        SINAD = sinad(inputSignal);
        SNR = snr(inputSignal);
        ShapeFactor = rms(inputSignal,'omitnan')/mean(abs(inputSignal),'omitnan');
        Skewness = skewness(inputSignal);
        Std = std(inputSignal,'omitnan');
        THD = thd(inputSignal);
        
        % 信号特徴を連結します。
        featureValues = [ClearanceFactor,CrestFactor,ImpulseFactor,Kurtosis,Mean,PeakValue,RMS,SINAD,SNR,ShapeFactor,Skewness,Std,THD];
        
        % 計算された特徴を table にパッケージ化します。
        featureNames = ["ClearanceFactor","CrestFactor","ImpulseFactor","Kurtosis","Mean","PeakValue","RMS","SINAD","SNR","ShapeFactor","Skewness","Std","THD"];
        data_stats = array2table(featureValues,'VariableNames',featureNames);
    catch
        % 計算された特徴を table にパッケージ化します。
        featureValues = NaN(1,13);
        featureNames = ["ClearanceFactor","CrestFactor","ImpulseFactor","Kurtosis","Mean","PeakValue","RMS","SINAD","SNR","ShapeFactor","Skewness","Std","THD"];
        data_stats = array2table(featureValues,'VariableNames',featureNames);
    end
    
    % member table に計算結果を追加します。
    memberResult = [memberResult, ...
        table({data_stats},'VariableNames',"data_stats")]; %#ok<AGROW>
    
    %% PowerSpectrum
    try
        % 計算されるスペクトルで使用する単位を取得します。
        tuReal = "seconds";
        tuTime = tuReal;
        
        % 有効なサンプリング レートを計算します。
        tNumeric = time2num(data.Time,tuReal);
        [Fs,irregular] = effectivefs(tNumeric);
        Ts = 1/Fs;
        
        % 等間隔でない信号をリサンプリングします。
        x = data.audioIn;
        if irregular
            x = resample(x,tNumeric,Fs,'linear');
        end
        
        % 自己回帰モデルを計算します。
        data = iddata(x,[],Ts,'TimeUnit',tuTime,'OutputName','SpectrumData');
        arOpt = arOptions('Approach','fb','Window','now','EstimateCovariance',false);
        model = ar(data,4,arOpt);
        
        % パワー スペクトルを計算します。
        [ps,w] = spectrum(model);
        ps = reshape(ps, numel(ps), 1);
        
        % Convert frequency unit.
        factor = funitconv('rad/TimeUnit', 'Hz', 'seconds');
        w = factor*w;
        Fs = 2*pi*factor*Fs;
        
        % ナイキスト周波数を超える周波数を削除します。
        I = w<=(Fs/2+1e4*eps);
        w = w(I);
        ps = ps(I);
        
        % 計算されるスペクトルを設定します。
        ps = table(w, ps, 'VariableNames', ["Frequency", "SpectrumData"]);
        ps.Properties.VariableUnits = ["Hz", ""];
        ps = addprop(ps, {'SampleFrequency'}, {'table'});
        ps.Properties.CustomProperties.SampleFrequency = Fs;
        data_ps = ps;
    catch
        data_ps = table(NaN, NaN, 'VariableNames', ["Frequency", "SpectrumData"]);
    end
    
    % member table に計算結果を追加します。
    memberResult = [memberResult, ...
        table({data_ps},'VariableNames',"data_ps")]; %#ok<AGROW>
    
    %% SpectrumFeatures
    try
        % スペクトル特徴を計算します。
        % 周波数単位の変換係数を取得します。
        factor = funitconv('Hz', 'rad/TimeUnit', 'seconds');
        ps = data_ps.SpectrumData;
        w = data_ps.Frequency;
        w = factor*w;
        mask_1 = (w>=factor*1.59154943091895e-21) & (w<=factor*7999.99999999999);
        ps = ps(mask_1);
        w = w(mask_1);
        
        % スペクトル ピークを計算します。
        [peakAmp,peakFreq] = findpeaks(ps,w/factor,'MinPeakHeight',-Inf, ...
            'MinPeakProminence',0,'MinPeakDistance',0.001,'SortStr','descend','NPeaks',2);
        peakAmp = [peakAmp(:); NaN(2-numel(peakAmp),1)];
        peakFreq = [peakFreq(:); NaN(2-numel(peakFreq),1)];
        
        % 個々の特徴値を抽出します。
        PeakAmp1 = peakAmp(1);
        PeakAmp2 = peakAmp(2);
        PeakFreq1 = peakFreq(1);
        PeakFreq2 = peakFreq(2);
        BandPower = trapz(w/factor,ps);
        
        % 信号特徴を連結します。
        featureValues = [PeakAmp1,PeakAmp2,PeakFreq1,PeakFreq2,BandPower];
        
        % 計算された特徴を table にパッケージ化します。
        featureNames = ["PeakAmp1","PeakAmp2","PeakFreq1","PeakFreq2","BandPower"];
        data_ps_spec = array2table(featureValues,'VariableNames',featureNames);
    catch
        % 計算された特徴を table にパッケージ化します。
        featureValues = NaN(1,5);
        featureNames = ["PeakAmp1","PeakAmp2","PeakFreq1","PeakFreq2","BandPower"];
        data_ps_spec = array2table(featureValues,'VariableNames',featureNames);
    end
    
    % member table に計算結果を追加します。
    memberResult = [memberResult, ...
        table({data_ps_spec},'VariableNames',"data_ps_spec")]; %#ok<AGROW>
    
    %% 現在のメンバーのすべての結果をアンサンブルに書き込みます。
    writeToLastMemberRead(outputEnsemble,memberResult)
end

% すべての特徴を table に収集します。
featureTable = readFeatureTable(outputEnsemble);

% Feature ranking for FeatureTable1
selectedFeatureNames = ["data_stats/ClearanceFactor","data_stats/CrestFactor","data_stats/ImpulseFactor","data_stats/Kurtosis","data_stats/Mean","data_stats/PeakValue","data_stats/RMS","data_stats/SINAD","data_stats/SNR","data_stats/ShapeFactor","data_stats/Skewness","data_stats/Std","data_stats/THD","data_ps_spec/PeakAmp1","data_ps_spec/PeakAmp2","data_ps_spec/PeakFreq1","data_ps_spec/PeakFreq2","data_ps_spec/BandPower"];

% Get selected features and labels for classification ranking
selectedFeatureValues = featureTable{:,selectedFeatureNames};
label = featureTable{:,"faultCode"};

% Convert label to numeric values
if iscategorical(label)
    label = string(label);
end
group = grp2idx(label);

% Initialize an empty matrix to store ranking scores
score = zeros(numel(selectedFeatureNames),0);

% Initialize a string array to store ranking method names
methodList = strings(0);

%% One-way ANOVA
% minmax を使用して特徴を正規化します。
fNorm = (selectedFeatureValues-min(selectedFeatureValues,[],1))./(max(selectedFeatureValues,[],1)-min(selectedFeatureValues,[],1));

% One-Way ANOVA を使用してランク付けスコアを計算します。
numFeatures = size(fNorm,2);
z = zeros(numFeatures,1);
for k = 1:numFeatures
    [~,tbl] = anova1(fNorm(:,k),group,'off');
    % 1 因子 ANOVA の出力から F 統計量を取得します。
    stats = tbl{2,5};
    if ~isempty(stats)
        z(k) = stats;
    end
end

% 新しいスコアとメソッド名を追加します。
score = [score,z];
methodList = [methodList,"1 因子 ANOVA"];


%% Create ranking result table
featureColumn = table(selectedFeatureNames(:),'VariableNames',{'Features'});
ranking = [featureColumn array2table(score,'VariableNames',methodList)];
ranking = sortrows(ranking,'1 因子 ANOVA','descend');

% SelectedVariables を設定して、アンサンブルから読み取る変数を選択します。
outputEnsemble.SelectedVariables = unique([outputEnsemble.DataVariables;outputEnsemble.ConditionVariables;outputEnsemble.IndependentVariables],'stable');

% 結果を table に収集します。
outputTable = readall(outputEnsemble);
end

% Copyright 2021 The MathWorks, Inc.