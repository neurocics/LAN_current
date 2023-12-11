function [imp_i] = BA2json(cfg) 
%    <*LAN)<] 
%    v.0.1
%
%  BA2jsonwrite  to    _chanels.tsv
%                       _electrodes.tsv    files 
% [imp]         aditional imput for impedance to bluid _electrode.tsv (see BVpoint2txt) 
%  BA2json(cfg)
% cfg.
%     filename  =  'sujeto.eeg'
%     elec_name  = {'Cz', ...} default = [];
%     elec_type = {'EEG' , ....}
%
% P Billeke 
% 07.12.2023  .json and .tsv following BIDS eeg format 


if nargin == 1 && isstruct(cfg)

    % file nams
    filename        = getcfg(cfg,'filename','');
    if isempty(filename)
        filename = ls('*.eeg');
        if filename(end)~='g';filename(end)=[];end
    end
    filename = strrep(filename,'.eeg','');
    elec_name  = getcfg(cfg,'elec_name',[]);
    elec_type  = getcfg(cfg,'elec_type',[]);
end


     % read vhdr
     [vhdr orig] = ft_read_header([filename '.vhdr']);
    
     lines = readlines([filename '.vhdr']);
     imp_ind = find(contains(lines,'Impedance [kOhm] at','IgnoreCase',true));
     lines = lines(imp_ind(end)+1:end);
     for e =1:length(lines)% e=01
         paso=char(lines(e));
         if numel(paso)>0

         %name   
         if isempty(elec_name)    
         names_i{e} = strrep(strrep(paso(1:5),':',''),' ','');
         elseif numel(elec_name) < e 
         names_i{e} = strrep(strrep(paso(1:5),':',''),' ','');
         else
         names_i{e} = elec_name{e};
         end

         %impedance
         imp_i{e} =strrep(strrep(paso(end-5:end),':',''),' ','');

         %type   
         if isempty(elec_type)    
         type_i{e} = 'EEG';
         elseif numel(elec_name) < e 
         type_i{e} = 'EEG';
         else
         type_i{e} = elec_type{e};
         end


         end
     end


     % read vmrk
      EVENT = ft_read_event([filename '.vmrk']);
      % delect no stim event 
      EVENT(ifcellis({EVENT.type},'Stimulus')==0)=[];

% write _event.tsv
  fileID_event = fopen([filename '_event.tsv'],'w');  
  fprintf(fileID_event,'%s \t','onset')
  fprintf(fileID_event,'%s \t','duration')
  fprintf(fileID_event,'%s \t','value')
  fprintf(fileID_event,'%s \n','stim_file')
 
  for t =1:length(EVENT)
      fprintf(fileID_event,'%3.4f \t',[EVENT(t).sample/vhdr.Fs]);
      fprintf(fileID_event,'%3.1f \t',EVENT(t).duration);
      fprintf(fileID_event,'%s \t',[EVENT(t).value]);
      fprintf(fileID_event,'%s \n','n/a');
  end
  fclose(fileID_event)

  % write _channel.tsv
  fileID_chan = fopen([filename '_chan.tsv'],'w');  
  fprintf(fileID_chan,'%s \t','name')
  fprintf(fileID_chan,'%s \t','type')
  fprintf(fileID_chan,'%s \t','unit')
  fprintf(fileID_chan,'%s \t','status')
  fprintf(fileID_chan,'%s \n','status_description')
  for e =1:length(names_i)

      fprintf(fileID_chan,'%s\t',names_i{e});
      fprintf(fileID_chan,'%s\t',type_i{e});
      fprintf(fileID_chan,'%s\t','microV');
      if isempty(str2num(imp_i{e}))
      fprintf(fileID_chan,'%s\t','bad');
      fprintf(fileID_chan,'%s\n','high impedance');
      else
      fprintf(fileID_chan,'%s\t','good');
      fprintf(fileID_chan,'%s\n','n/a');
      end
  end
  fclose(fileID_event)
end
    