function [HDR] = save2bkr(arg1,arg2,arg3);
% SAVE2BKR loads EEG data and saves it in BKR format
%
%       HDR = save2bkr(sourcefile [, destfile [, option]]);  
%
%       HDR = eegchkhdr();
%	HDR = save2bkr(HDR,data);
%
%   sourcefile	source file CNT, EDF, BKR, MAT, etc. format
%   destfile	destination file in BKR format 
%	if destfile is empty, sourcefile but with extension .bkr is used.
%   option
%       gain            Gain factor for unscaled EEG data (e.g. old Matlab files) 
%       'removeDC'      removes mean
%       'autoscale k:l'	uses only channels from k to l for scaling
%       'removeDC+autoscale k:l'	combines both   
%   HDR		Header, HDR.FileName must contain target filename
%   data	data samples
%
%
% see also: EEGCHKHDR

%	$Revision: 1.4 $
% 	$Id: save2bkr.m,v 1.4 2003-02-10 14:52:53 schloegl Exp $
%	Copyright (C) 2002-2003 by Alois Schloegl <a.schloegl@ieee.org>		

% This library is free software; you can redistribute it and/or
% modify it under the terms of the GNU Library General Public
% License as published by the Free Software Foundation; either
% Version 2 of the License, or (at your option) any later version.
%
% This library is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Library General Public License for more details.
%
% You should have received a copy of the GNU Library General Public
% License along with this library; if not, write to the
% Free Software Foundation, Inc., 59 Temple Place - Suite 330,
% Boston, MA  02111-1307, USA.


FLAG_REMOVE_DC = 0;
chansel = 0; 

if nargin<2, arg2=[]; end;

if nargin<3,
        cali = NaN;
elseif isnumeric(arg3)
        cali = arg3;        
else
        FLAG_REMOVE_DC = findstr(arg3,'removeDC');        
        tmp = findstr(arg3,'autoscale');
        if ~isempty(tmp);
                chansel = arg3(tmp+9:length(arg3));
                tmp = str2num(chansel);
                if isempty(tmp),
                        fprintf(2,'invalid autoscale argument %s',chansel);
                        return;
                end;
                chansel = tmp;
        end;
end;

if isstr(arg1), 
	filename = arg1;	% input  file 
	if isempty(arg2),	% output file
		ix = max(find(arg1=='.'));
		HDR.FileName = [arg1(1:ix-1),'.bkr'];
	else
		HDR.FileName = arg2;
	end;
elseif isstruct(arg1) & isnumeric(arg2),
	HDR  = arg1;
	data = arg2;
end;		

if isstruct(arg1),
        %HDR.FileName 	= destfile;	% Assign Filename
	if isfield(HDR,'NS')
		if HDR.NS==size(data,2),
			% It's ok. 
		elseif HDR.NS==size(data,1),
			warning('data is transposed\n');
			data = data';
		else
			fprintf(2,'HDR.NS=%i is not equal number of data columns %i\n',HDR.NS,size(data,2));
			return;
		end;				
	else
	        HDR.NS = size(data,2);	% number of channels
	end;
        if ~isfield(HDR,'NRec'),
                HDR.NRec = 1;		% number of trials (1 for continous data)
        end;	
        HDR.SPR 	= size(data,1)/HDR.NRec;	% number of samples per trial
        %HDR.SampleRate	= 100;		% Sampling rate
        %HDR.Label  	= hdr.Label; % Labels, 
        
        %HDR.PhysMax 	= max(abs(data(:)));	% Physical maximum 
        %HDR.DigMax 	= max(2^15-1);		% Digital maximum
        % --- !!! Previous scaling gave an error up to 6% and more !!! ---
        
        %HDR.Filter.LowPass  = 30;	% upper cutoff frequency
        %HDR.Filter.HighPass = .5;	% lower cutoff frequency
        HDR.FLAG.REFERENCE   = ' ';	% reference '', 'LOC', 'COM', 'LAP', 'WGT'
        %HDR.FLAG.REFERENCE  = HDR.Recording;
        HDR.FLAG.TRIGGERED   = HDR.NRec>1;	% Trigger Flag
        
        if FLAG_REMOVE_DC,
                %y = center(y,1);
                data = data - repmat(mean(data,1),size(data,1),1);
        end;
        if chansel==0,
                HDR.PhysMax = max(abs(data(:))); %gives max of the whole matrix
                data = data*(HDR.DigMax/HDR.PhysMax);	%transpose, da zuerst 1.Sample-1.Channel, dann 
        else
                tmp = data(:,chansel);
                HDR.PhysMax = max(abs(tmp(:))); %gives max of the whole matrix
                for k = 1:HDR.NS,
                        if any(k==chansel),
                                data(:,k) = data(:,k)*HDR.DigMax/HDR.PhysMax;
                        else
	                        mm = max(abs(data(:,k)));
                                data(:,k) = data(:,k)*HDR.DigMax/mm;
                        end;
                end;
        end;
        
        HDR = eegopen (HDR,'w',0,'UCAL');     	% OPEN BKR FILE
        HDR = eegwrite(HDR,data);  	% WRITE BKR FILE
        HDR = eegclose(HDR);            % CLOSE BKR FILE

	% save Classlabels
	if isfield(HDR,'Classlabel'),
		fid = fopen([HDR.FileName(1:length(HDR.FileName)-4) '.par'],'w');
        	fprintf(fid, '%i\r\n', HDR.Classlabel);
        	fclose(fid);
	end;
        return;
end;

[pf,fn,ext] = fileparts(filename);

if strcmp(upper(ext(2:4)),'MAT'),	
        tmp = load(filename);
	if isfield(tmp,'y')
                y=tmp.y;
                HDR.SampleRate=128;
        elseif isfield(tmp,'eeg');
                y=tmp.eeg;
                if ~isfield(tmp,'SampleRate')
                        warning(['Samplerate not known in ',filename,'. 128Hz is chosen']);
                        HDR.SampleRate=128;
                else
                        HDR.SampleRate=tmp.SampleRate;
                end;
                
        elseif isfield(tmp,'P_C_S');	% G.Tec Version 1.02 data format
                if tmp.P_C_S.version~=1.02,
                        fprintf(2,'Warning: PCS-Version is not 1.02 but %4.2f.\n');
                end;
                sz = size(tmp.P_C_S.data);
                
                y  = repmat(NaN,sz(1)*sz(2),sz(3)); 
                for k1 = 1:sz(1),
                        y((k1-1)*sz(2)+(1:sz(2)),:) = squeeze(tmp.P_C_S.data(k1,:,:));
                end;
                
                HDR.SampleRate = tmp.P_C_S.samplingfrequency;
                HDR.NRec = sz(1);
                HDR.SPR  = sz(2);
                HDR.Dur  = sz(2)/HDR.SampleRate;
                HDR.NS   = sz(3);
                HDR.Filter.LowPass = tmp.P_C_S.lowpass;
                HDR.Filter.HighPass = tmp.P_C_S.highpass;
                HDR.Filter.Notch = tmp.P_C_S.notch;
                cali=1;
                                
        elseif isfield(tmp,'P_C_DAQ_S');
                y=double(tmp.P_C_DAQ_S.data{1});
                %HDR.PhysDim=tmp.P_C_DAQ_S.unit;     %propriatory information
                %scale=tmp.P_C_DAQ_S.sens;         %propriatory information
                HDR.SampleRate=tmp.P_C_DAQ_S.samplingfrequency;
                
        elseif isfield(tmp,'data');
                y=tmp.data;
                if ~isfield(tmp,'SampleRate')
                        warning(['Samplerate not known in ',filename,'. 128Hz is chosen']);
                        HDR.SampleRate=128;
                else
                        HDR.SampleRate=tmp.SampleRate;
                end;
                
        elseif isfield(tmp,'EEGdata');
                y=tmp.EEGdata;
                classlabel = tmp.classlabel;
                if ~isfield(tmp,'SampleRate')
                        warning(['Samplerate not known in ',filename,'. 128Hz is chosen']);
                        HDR.SampleRate=128;
                else
                        HDR.SampleRate=tmp.SampleRate;
                end;
                
        elseif isfield(tmp,'daten');	% Michi's EP daten
                HDR.NS=size(tmp.daten.raw,2)-1;
                y=tmp.daten.raw(:,1:HDR.NS)*100;
                cali=1;                
                if ~isfield(tmp,'SampleRate')
                        warning(['Samplerate not known in ',filename,'. 2000Hz is chosen']);
                        HDR.SampleRate=2000;
                else
                        HDR.SampleRate=tmp.SampleRate;
                end;
                HDR.PhysDim='�V';
                
        elseif isfield(tmp,'neun') & isfield(tmp,'zehn') & isfield(tmp,'trig');
                y=[tmp.neun;tmp.zehn;tmp.trig];
                if ~isfield(tmp,'SampleRate')
                        warning(['Samplerate not known in ',filename,'. 128Hz is chosen']);
                        HDR.SampleRate=128;
                else
                        HDR.SampleRate=tmp.SampleRate;
                end;
        end;        
        
        if isnan(cali),
                warning(['Calibration not defined in ',filename]);
                cali=input('What was the sensitivity? ');
        end;
        y = y*cali;        
else
	HDR = eegopen(filename,'r',0);
        [y,HDR] = eegread(HDR);
        HDR = eegclose(HDR);
end;

if ~isfield(HDR,'NS'),
        warning(['number of channels undefined in ',filename]);
        HDR.NS = size(y,2);
end;
if ~isfield(HDR,'NRec'),
        HDR.NRec = 1;
end;
if ~isfield(HDR,'SPR'),
        HDR.SPR = size(y,1)/HDR.NRec;
end;

if FLAG_REMOVE_DC,
        y = y-repmat(mean(y,1),size(y,1),1);
end;

HDR.DigMax=2^15-1;
if chansel==0,
	HDR.PhysMax = max(abs(y(:))); %gives max of the whole matrix
        y = y*(HDR.DigMax/HDR.PhysMax);	%transpose, da zuerst 1.Sample-1.Channel, dann 
else
        tmp = y(:,chansel);
        HDR.PhysMax = max(abs(tmp(:))); %gives max of the whole matrix
        for k = 1:HDR.NS,
                mm = max(abs(y(:,k)));
                if any(k==chansel),
                        y(:,k) = y(:,k)*HDR.DigMax/HDR.PhysMax;
                else
                        y(:,k) = y(:,k)*HDR.DigMax/mm;
                end;
        end;
end;

tmp = round(HDR.PhysMax);
fprintf(1,'Rounding of PhysMax yields %f%% error.\n',abs((HDR.PhysMax-tmp)/tmp)*100);
HDR.PhysMax = tmp;
HDR.TYPE = 'BKR';
HDR.FLAG.REFERENCE = ' ';

HDR = eegchkhdr(HDR);

fid   = fopen(HDR.FileName,'w+','ieee-le');
count = fwrite(fid,207,'short');	        % version number of header
count = fwrite(fid,HDR.NS  ,'short');	        % number of channels
count = fwrite(fid,HDR.SampleRate,'short');     % sampling rate
count = fwrite(fid,HDR.NRec,'uint32');          % number of trials: 1 for untriggered data
count = fwrite(fid,HDR.SPR ,'uint32');          % samples/trial/channel
count = fwrite(fid,HDR.PhysMax,'short');        % Kalibrierspannung
count = fwrite(fid,HDR.DigMax ,'short');        % Kalibrierwert
count = fwrite(fid,zeros(4,1),'char');        

count = fwrite(fid,[HDR.Filter.LowPass(1),HDR.Filter.HighPass(1)],'float'); 
count = fwrite(fid,zeros(16,1),'char');         % offset 30

count = fwrite(fid,HDR.FLAG.TRIGGERED,'int16');	% offset 32
count = fwrite(fid,zeros(24,1),'char');         % offset 46
tmp   = [strcmp(HDR.FLAG.REFERENCE,'COM')|strcmp(HDR.FLAG.REFERENCE,'CAR'), strcmp(HDR.FLAG.REFERENCE,'LOC')|strcmp(HDR.FLAG.REFERENCE,'LAR'), strcmp(HDR.FLAG.REFERENCE,'LAP'), strcmp(HDR.FLAG.REFERENCE,'WGT')];
count = fwrite(fid,tmp,'int16'); 			% offset 72 + 4*BOOL

%speichert den rest des BKR-headers
count = fwrite(fid,zeros(1024-80,1),'char');
% writes data
count = fwrite(fid,y','short');
fclose(fid);

% save classlabels
if exist('classlabel')==1,
        fid = fopen([HDR.FileName(1:length(HDR.FileName)-4) '.par'],'w');
        fprintf(fid, '%i\r\n', classlabel);
        fclose(fid);
end;
