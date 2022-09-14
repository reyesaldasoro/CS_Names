clear all
close all

%% Find out the occurrence of names in City Research Online

%allF                    = '%5BAll%20Fields%5D'; % all fields code
%allF2                    = '%5BMeSH%20Terms%5D'; % all fields code
basicURL                = 'https://openaccess.city.ac.uk/cgi/search/archive/advanced?&creators_name=';
%%
% retrieve names
names;
numAcademics        = numel(CS_LastNames);
combinedEntries     = zeros(numAcademics);
for counterKW = 1:numAcademics
    disp(counterKW)
    %     spacePosition       = strfind(CS_Names{counterKW},' ');
    %     firstName           = CS_Names{counterKW}(1:spacePosition-1);
    %     lastName            = CS_Names{counterKW}(spacePosition+1:end);
    for counterKW2 = counterKW   %:numAcademics
        %         spacePosition2       = strfind(CS_Names{counterKW2},' ');
        %         firstName2           = CS_Names{counterKW2}(1:spacePosition2-1);
        %         lastName2            = CS_Names{counterKW2}(spacePosition2+1:end);
        %        urlAddress                          = strcat(basicURL,strcat(firstName,'+',lastName,'+',firstName2,'+',lastName2));
        if counterKW==counterKW2
            urlAddress                          = strcat(basicURL,strcat(strrep(CS_LastNames{counterKW},' ','+')));
        else
%            urlAddress                          = strcat(basicURL,strcat(strrep(lastNames{counterKW},' ','+'),'+',strrep(lastNames{counterKW2},' ','+')));
            urlAddress                          = strcat(basicURL,strcat('%28',strrep(lastNames2{counterKW},' ','+'),'%5BAuthor%5D%29+AND+%28',strrep(lastNames2{counterKW2},' ','+'),+'%5BAuthor%5D%29'));
%https://pubmed.ncbi.nlm.nih.gov/?term=%28Moore+N+%5BAuthor%5D%29+AND+%28McEntee+M+%5BAuthor%5D%29&sort=pubdate&size=50
        end
        PubMedURL                           = urlread(urlAddress);
        %locCount_init                       = strfind(PubMedURL,'data-results-amount');
        %locCount_fin                        = strfind(PubMedURL(locCount_init+21:locCount_init+300),'"');
        locCount_init                       = strfind(PubMedURL,'>Export');
        locCount_fin                        = strfind(PubMedURL,'results as');
        % Determine the number of entries with the selected key words
%         if ~isempty(locCount_init)
%             numEntriesPubMed                    = (PubMedURL(locCount_init+16:locCount_init+16+locCount_fin(1)-2));
%         else
%             found1result                     = strfind(PubMedURL,'found one');
%             if ~isempty(found1result)
%                 numEntriesPubMed = '1';
%             else
%                 numEntriesPubMed = '0';
%             end
%         end
        
        combinedEntries(counterKW,counterKW2) = str2double(PubMedURL(locCount_init+7:locCount_fin-1));
        combinedEntries(counterKW2,counterKW) = str2double(PubMedURL(locCount_init+7:locCount_fin-1));
        %combinedEntries(counterKW) = str2double(numEntriesPubMed);
    end
end

%%


figure(2)
methodGraph={'circle', 'force', 'layered', 'subspace', 'force3','subspace3'};
G = graph(combinedEntries,CS_LastNames,'omitselfloops');
    
