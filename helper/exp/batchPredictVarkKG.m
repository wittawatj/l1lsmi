function batchPredictVarkKG( expnum, dataset )
%
% Evaluate the selected features by vark functions with Knn/Gaussian regression.
% For efficiency, for each dataset, an evaluation result is kept
% for each feature subset found. This is written to a file called 
% "<dataset>-knngauss.mat"
%
% For each k-feature subset, an average of Knn/Gauss. error over all trials is
% calculated. Note that it is possible that not all trials have k-feature
% subset. In that case, an average is taken over the available results. 
%
% For practical reason, only subset with less than or equal to 100 features
% will be evaluated.
% 


if nargin < 2
    Dats = getAllDatasets(expnum);
    for di =1:length(Dats)
        da = Dats{di};
        predictVark(expnum, da);
    end
else
    predictVark(expnum, dataset);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


function predictVark(expnum, dataset)
    features_limit = 500;
    Folders = dir(sprintf('exp%sexp%d%s%s-*', filesep, expnum, filesep, dataset));

    % Cache path of Knn/Gauss.
    cachePath = sprintf('exp/exp%d/%s-knngauss.mat', expnum, dataset);
    if exist(cachePath, 'file') == 2
        load(cachePath);
    else
        % r x m matrix where r is the number of feature subsets found so far.
        FMatCache = logical([]);

        % r x 1 column vector corresponding to FMatCache
        PredictCache = [];
    end

    for fi=1:length(Folders)
        if Folders(fi).isdir

            fname = Folders(fi).name;
            Match = regexp(fname, '(?<data>[\w_\d]+)[-](?<method>[\w_\d]+)', 'names');
            met = Match.method;

            TrialFiles = dir(sprintf('exp%sexp%d%s%s%s*-*.mat', filesep, expnum, ...
                filesep, fname, filesep));

            FMat = [];
            Predict = [];
            for ti=1:length(TrialFiles)
                tfname = TrialFiles(ti).name;
                tffull = sprintf('exp/exp%d/%s/%s', expnum, fname, tfname);
                load(tffull);

                S = sum(VK.FMat,2);
                m = size(VK.FMat, 2);
                % not evaluate if the feature size is too big
                RFMat = VK.FMat(and(S>0, and(S<=features_limit, ...
                    mod(S-1, feature_step(m))==0)),:);
                % Go through each selected feature subset and evaluate with
                % Knn/ Gaussian regression.
                predictTemp = nan(size(RFMat,1), 1);
                
                for ri=1:size(RFMat,1)
                    F = logical(RFMat(ri, :));
                    [cached, loc] = ismember(F, FMatCache, 'rows');
                    if cached % cache hit
                        err = PredictCache(loc);
                    else % cache missed
                        FX = X(F,:); % X is in the loaded result
                        KG = knngauss_error( FX, Y );
                        err = KG.learner_err ;

                        % Keep in the cache
                        FMatCache(end+1, :) = F;
                        PredictCache(end+1) = err;
                        
                        % Save cache
                        save(cachePath, 'FMatCache', 'PredictCache');
                    end
                    predictTemp(ri) = err;
                end

                FMat = [FMat ; RFMat];
                Predict = [Predict ; predictTemp];
                clear VK predictTemp
            end

            % for each k-feature subset, find the average of the errors
            SK = sum(FMat, 2);
            m = size(FMat,2);
            AvgErr = nan(m, 1);
            K = unique(SK);
            for ki=1:length(K)
                k = K(ki);
                Ind = SK==k;
                Predictk = Predict(Ind);
                AvgErr(k) = mean(Predictk);
            end

            % Save result
            resultPath = sprintf('exp/exp%d/%s-%s-knngauss.mat', expnum, dataset, met);
            save(resultPath, 'AvgErr', 'FMat', 'Predict', 'met', 'expnum')
        end
    end

    % Save cache
    save(cachePath, 'FMatCache', 'PredictCache');

end

function s=feature_step(m)
    if m <= 50
        s = 1;
    elseif m <= 200
        s=2;
    elseif m <= 400
        s=3;
    else
        s=4;
    end
%         ceil(size(VK.FMat,2)/30)
end