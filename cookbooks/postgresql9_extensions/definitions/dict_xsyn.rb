define :postgresql9_dict_xsyn do
 dbname_to_use = params[:name]  
 
  load_sql_file do 
    db_name dbname_to_use
    extname "dict_xsyn"
    supported_versions %w[9.0 9.1]
  end

end