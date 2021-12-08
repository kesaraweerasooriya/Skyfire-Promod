//The function to connect to mySQL database. This function will be called automatically when we use getRow Function or Qexec Function. 
//No need to call manually.
sqlConnect(){
	if(isDefined(game["sql_db"]))
		return true;

	level.sql["host"] = getdvar("sql_host");
	level.sql["user"] = getdvar("sql_user");
	level.sql["password"] = getdvar("sql_password");
	level.sql["port"] = getdvarint("sql_port");
	level.sql["database"] = getdvar("sql_database");

	if(level.sql["port"] == 0){
		level.sql["port"] = 3306;
	}

	game["sql_db"] = mysql_real_connect(level.sql["host"], level.sql["user"], level.sql["password"], level.sql["database"], level.sql["port"]);

	if(!isDefined(game["sql_db"])){
		errorNotify("MYSQL database connection error! Check the settings.");
		return false;
	}

	game["sqlTable"] = [];

	for(i=0; i<level.tables.size; i++){
		table = [[level.tables[i]]]();

		initTable(table[0], table[1]);
	}

	return true;
}

//Every table declaration should be called through this function.
initTable(table, query){
	Qexec(query);
	game["sqlTable"][table] = true;
}

getRow(query){
	if(!sqlConnect())
		return;

	debugSQLQuery(query);
	mysql_query(game["sql_db"], query);

	if(mysql_num_rows(game["sql_db"]) == 1)
		return mysql_fetch_row(game["sql_db"]);
	else
		return;
}

getRows(query){
	if(!sqlConnect())
		return;

	debugSQLQuery(query);
	mysql_query(game["sql_db"], query);

	if(mysql_num_rows(game["sql_db"]) > 0)
		return mysql_fetch_rows(game["sql_db"]);
	else
		return;
}

//Alternate if mysql_fetch_rows function fails.
/*getRows(query){
	if(!sqlConnect())
		return;

	//debugsql(query);
	mysql_query(game["sql_db"], query);
	aff_rows = mysql_num_rows(game["sql_db"]);

	if(aff_rows != 0){
		for(i=0; i<aff_rows; i++)
			array = mysql_fetch_row(game["sql_db"]);
		return array;
	}
	else
		return;
}*/


Qexec(query){
	if(!sqlConnect())
		return;

	debugSQLQuery(query);
	mysql_query(game["sql_db"], query);
}

/*selectQuery(table, columns, where){

	query = "SELECT ";
	if(isString(columns)){
		if(columns == "*")
			query += "* ";
		else
			query += columns+" ";
	}
	else if()
}*/

closeSession(){
	mysql_close(game["sql_db"]);
	debugSQLQuery("Datbase connection Closed");
}

errorNotify(text){
	print("MYSQL:: Error: "+text+"\n");
}

debugSQLQuery(text){
	if(getDvarInt("debug_sql_queries"))
		print("^2SQL log::\n"+text+"\n^1END SQL log.\n\n");
}