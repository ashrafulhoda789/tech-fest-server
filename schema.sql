CREATE TABLE IF NOT EXISTS fests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    start_date TEXT NOT NULL,
    end_date TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS fest_days (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    fest_id INTEGER NOT NULL,
    day_number TEXT NOT NULL,
    date_str TEXT NOT NULL,  
    theme TEXT,              
    FOREIGN KEY (fest_id) REFERENCES fests(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS fest_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    day_id INTEGER NOT NULL,
    start_time TEXT NOT NULL, 
    end_time TEXT NOT NULL,  
    category TEXT,           
    title TEXT NOT NULL,     
    description TEXT,               
    FOREIGN KEY (day_id) REFERENCES fest_days(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS speakers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    image TEXT,
    designation TEXT NOT NULL,
    country TEXT,
    description TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS admins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT,
    email TEXT NOT NULL,
    phone TEXT,
    organisation TEXT,
    subject TEXT,
    message TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS registrations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT,
    email TEXT NOT NULL,
    whatsapp TEXT,
    organisation TEXT,
    attending_as TEXT DEFAULT 'Participant',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);