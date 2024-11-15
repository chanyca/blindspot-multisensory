classdef Directory
    properties
        userID
        baseDir
    end
    properties (Dependent)
        helperDir
        BSdataDir
        dataDir
        edfDir
        plotDir        
        allDataMat
    end
    methods
        function obj = Directory()
            obj.userID = extractBetween(pwd,['Users',filesep], filesep);
            obj.baseDir = pwd;
        end

        function helperDir = get.helperDir(obj)
            helperDir = char(fullfile(obj.baseDir, 'helper'));
        end

        function BSdataDir = get.BSdataDir(obj)
            BSdataDir = char(fullfile(obj.baseDir, 'bs_data'));
        end

        function dataDir = get.dataDir(obj)
            dataDir = char(fullfile(obj.baseDir, 'Data'));
        end

        function edfDir = get.edfDir(obj)
            edfDir = char(fullfile(obj.dataDir, 'edf'));
        end

        function plotDir = get.plotDir(obj)
            plotDir = char(fullfile(obj.baseDir, 'plots'));
        end

        function allDataMat = get.allDataMat(obj)
            allDataMat = char(fullfile(obj.dataDir, 'allData.mat'));
        end
    end
end
