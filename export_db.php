<?php
try {
    $dbPath = __DIR__ . '/backend/database/database.sqlite';
    if (!file_exists($dbPath)) {
        die('SQLite DB not found');
    }
    
    $pdo = new PDO('sqlite:' . $dbPath);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    $tablesQuery = $pdo->query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
    $tables = $tablesQuery->fetchAll(PDO::FETCH_COLUMN);
    
    $output = "SET FOREIGN_KEY_CHECKS=0;\r\n\r\n";
    
    foreach ($tables as $table) {
        $rowsQuery = $pdo->query("SELECT * FROM $table");
        $rows = $rowsQuery->fetchAll(PDO::FETCH_ASSOC);
        
        if (empty($rows)) continue;
        
        $output .= "-- Data for $table\r\n";
        
        foreach ($rows as $row) {
            $cols = array_keys($row);
            $colsStr = implode(', ', array_map(function($c) { return "`" . $c . "`"; }, $cols));
            
            $vals = array_values($row);
            $valsStr = implode(', ', array_map(function($v) {
                if ($v === null) return 'NULL';
                if (is_numeric($v)) return "'$v'";
                return "'" . str_replace("'", "''", $v) . "'";
            }, $vals));
            
            $output .= "INSERT INTO `$table` ($colsStr) VALUES ($valsStr);\r\n";
        }
        $output .= "\r\n";
    }
    
    $output .= "SET FOREIGN_KEY_CHECKS=1;\r\n";
    
    file_put_contents(__DIR__ . '/backend/database_mysql_export.sql', $output);
    echo "Exported successfully.";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
