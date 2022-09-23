function [ result ] = Matrix2GraphML( adjMatrix, filePath, varargin )
%Matrix2GraphML Conversion d'une matrice d'adjacence en fichier GraphML
%   Le graphe est de type dirig�
%   Les id des noeuds suivent la syntaxe 'n<num�ro_ligne>'
%   Les id des arr�tes suivent la syntaxe 'e<num�ro_ligne_source><num�ro_colonne_destination>
%   Les poids d'adjacence sont report�s dans la cl� 'd1' des arr�tes
%   adjMatrix   : matrice d'adjacence
%   filePath    : nom du fichier r�sultant (p.e. 'out_file.graphml')
%   varargin1   : *optionel* vecteur de labels pour les noeuds
%                 p.e. [1 0 0 3 5] <= int
%                 p.e. ["A1" "B0" "C2" "D3" "E4"] <= string array
%                    c.f. web(fullfile(docroot, 'matlab/ref/isstring.html'))
%   result      : [nodeCount, edgeCount]
% .. Examples :
%    Matrix2GraphML(A, 'C:\Temp\mat_01.graphml');
%    Matrix2GraphML(A, 'C:\Temp\mat_01.graphml', [1 0 2 4 3]);
%    Matrix2GraphML(A, 'C:\Temp\mat_01.graphml', ["A1" "B3" "C2" "E2"]);
% ..versionChanged : 2017-07-01
%   Prise en compte d'arguments compl�mentaires variables pour l'insertion
%   de m�tadonn�es de noeuds.

% TODO : r�duire les noeuds r�pertori�s � ceux effectivement connect�s.
% TODO : prise en charge ou non de l'insertion d'une m�tadonn�e d'arr�te

% Arguments variables
% web(fullfile(docroot, 'matlab/ref/varargin.html'))
nVarargs = length(varargin);
   
% Verbes et syntaxe XML & GraphML ...
gmlXMLBracketOpen   = '<';
gmlXMLBracketClose  = '>';
gmlXMLNodeEnd       = '/';

gmlCR               = '\r\n';
gmlTab              = '\t';
gmlSpace            = '\040';

gmlMsg01          = '<?xml version="1.0" encoding="UTF-8" standalone="no"?>';
gmlMsg02          = '<!--Created by MATLAB::Matrix2GraphML-->';

gmlVerbGraphML      = 'graphml';
gmlVerbSchema       = 'xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns"';
gmlVerbGraph        = 'graph';
gmlVerbGraphType    = 'edgedefault="directed" id="G"';
gmlVerbNode         = 'node'; % p.e. : '<node id="n0">'
gmlVerbId           = 'id';
gmlVerbEdge         = 'edge';
gmlVerbSource       = 'source';
gmlVerbTarget       = 'target';
gmlVerbData         = 'data';
gmlVerbKey          = 'key';

strGraphMLStart = strcat(gmlXMLBracketOpen, gmlVerbGraphML, gmlSpace, gmlVerbSchema, gmlXMLBracketClose, gmlCR);
strGraphMLEnd = strcat(gmlXMLBracketOpen, gmlXMLNodeEnd, gmlVerbGraphML, gmlXMLBracketClose, gmlCR);

strGraphStart = strcat(gmlTab, gmlXMLBracketOpen, gmlVerbGraph, gmlSpace, gmlVerbGraphType, gmlXMLBracketClose, gmlCR);
strGraphEnd = strcat(gmlTab, gmlXMLBracketOpen, gmlXMLNodeEnd, gmlVerbGraph, gmlXMLBracketClose, gmlCR);

strDefKeyWeigth = strcat(gmlTab, gmlXMLBracketOpen, gmlVerbKey, gmlSpace, 'attr.name="edge_weigth" attr.type="string" for="edge" id="d1"', gmlXMLNodeEnd, gmlXMLBracketClose, gmlCR);
strFormatDefKeyNodeLabel = strcat(gmlTab, gmlXMLBracketOpen, gmlVerbKey, gmlSpace, 'attr.name="label" attr.type="', '%s', '" for="node" id="d2"', gmlXMLNodeEnd, gmlXMLBracketClose, gmlCR);

strFormatNode = strcat(gmlTab, gmlTab, gmlXMLBracketOpen, gmlVerbNode, gmlSpace, gmlVerbId, '=', '"', 'n%d', '"', gmlXMLNodeEnd, gmlXMLBracketClose, gmlCR);
strFormatNodeStart = strcat(gmlTab, gmlTab, gmlXMLBracketOpen, gmlVerbNode, gmlSpace, gmlVerbId, '=', '"', 'n%d', '"', gmlXMLBracketClose, gmlCR);
strNodeEnd = strcat(gmlTab, gmlTab, gmlXMLBracketOpen, gmlXMLNodeEnd, gmlVerbNode, gmlXMLBracketClose, gmlCR);
% strFormatEdgeSingle = strcat(gmlTab, gmlTab, gmlXMLBracketOpen,
% gmlVerbEdge, gmlSpace, gmlVerbId, '=', '"', 'e%d%d', '"', gmlSpace,
% gmlVerbSource, '=', '"', 'n%d', '"', gmlSpace, gmlVerbTarget, '=', '"',
% 'n%d', '"', gmlXMLNodeEnd, gmlXMLBracketClose, gmlCR); ... cf. TODO
strFormatEdgeStart = strcat(gmlTab, gmlTab, gmlXMLBracketOpen, gmlVerbEdge, gmlSpace, gmlVerbId, '=', '"', 'e%d%d', '"', gmlSpace, gmlVerbSource, '=', '"', 'n%d', '"', gmlSpace, gmlVerbTarget, '=', '"', 'n%d', '"', gmlXMLBracketClose, gmlCR);
strEdgeEnd = strcat(gmlTab, gmlTab, gmlXMLBracketOpen, gmlXMLNodeEnd, gmlVerbEdge, gmlXMLBracketClose, gmlCR);
strFormatData = strcat(gmlTab, gmlTab, gmlTab, gmlXMLBracketOpen, gmlVerbData, gmlSpace, gmlVerbKey, '=', '"', '%s', '"', gmlXMLBracketClose, '%d', gmlXMLBracketOpen, gmlXMLNodeEnd, gmlVerbData, gmlXMLBracketClose, gmlCR);
strFormatDataFromString = strcat(gmlTab, gmlTab, gmlTab, gmlXMLBracketOpen, gmlVerbData, gmlSpace, gmlVerbKey, '=', '"', '%s', '"', gmlXMLBracketClose, '%s', gmlXMLBracketOpen, gmlXMLNodeEnd, gmlVerbData, gmlXMLBracketClose, gmlCR);

% Test de matrice carr�e ...
if (size(adjMatrix,1) ~= size(adjMatrix,2))
    error('Matrix2GraphML:argCheck', 'adjMatrix is not a square matrix !')
end

% Test du vecteur de labels
nodeLabels_exists = false;
if nVarargs > 0
    nodeLabels = varargin{1};
    if (size(nodeLabels,2) ~= size(adjMatrix,2))
        error('Matrix2GraphML:argCheck', 'nodeLabels has not the same size [X,1] of the adjacency matrix !')
    end
    nodeLabels_exists = true;
end

% Initialisation ...
edgeCount = 0;
nodeCount = 0;
matSize = size(adjMatrix, 1);

% Cr�ation du fichier ...
fid = fopen(filePath, 'w');

% Ecriture des en-t�tes ...
fprintf(fid, strcat(gmlMsg01, gmlCR));
fprintf(fid, strcat(gmlMsg02, gmlCR));
fprintf(fid, strGraphMLStart);
fprintf(fid, strDefKeyWeigth); % ... cf. TODO
if nodeLabels_exists
    if isstring(nodeLabels)
        fprintf(fid, sprintf(strFormatDefKeyNodeLabel, "string"));
    else
        fprintf(fid, sprintf(strFormatDefKeyNodeLabel, "int"));
    end
end
fprintf(fid, strGraphStart);

% Parcours des noeuds ...
for i = 1 : matSize
    if nodeLabels_exists == false
        gmlNode = sprintf(strFormatNode, i);
        fprintf(fid, gmlNode);
    else
        gmlNode = sprintf(strFormatNodeStart, i);
        if isstring(nodeLabels)
            gmlNodeData = sprintf(strFormatDataFromString, 'd2', nodeLabels(1,i));
        else
            gmlNodeData = sprintf(strFormatData, 'd2', nodeLabels(1,i));
        end
        fprintf(fid, gmlNode);
        fprintf(fid, gmlNodeData);
        fprintf(fid, strNodeEnd);
    end
    nodeCount = nodeCount + 1;
end

% Parcours des arr�tes ...
for i = 1 : matSize
    for j = 1 : matSize
        if (adjMatrix(i,j) ~= 0)
            %gmlEdge = sprintf(strFormatEdge, i, j, i, j); ... cf. TODO.
            gmlEdge = sprintf(strFormatEdgeStart, i, j, i, j);
            gmlWeigth = sprintf(strFormatData, 'd1', adjMatrix(i,j));
            fprintf(fid, gmlEdge);
            fprintf(fid, gmlWeigth);
            fprintf(fid, strEdgeEnd);
            edgeCount = edgeCount + 1;
        end
    end
end

% Ecriture des terminaisons ...
fprintf(fid, strGraphEnd);
fprintf(fid, strGraphMLEnd);

% Fermeture du fichier ...
fclose(fid);

% Retour ...
result = [nodeCount edgeCount];
end