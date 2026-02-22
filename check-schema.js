const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
    'https://pobcyzoegcthaqrpacau.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvYmN5em9lZ2N0aGFxcnBhY2F1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzMjE1OTMsImV4cCI6MjA3OTg5NzU5M30.Q4kMbU86-F7f0nuYP2YpfAkmwZ4bPqOFpmC0xxG83-c'
);

async function checkColumns() {
    console.log("Checking columns for 'schedules' table...");
    // Hack to get column names: select 1 row and check keys
    const { data, error } = await supabase.from('schedules').select('*').limit(1);
    if (error) {
        console.error("Error fetching from schedules:", error);
    } else if (data && data.length > 0) {
        console.log("Columns:", Object.keys(data[0]));
    } else {
        // If no data, try to select something that doesn't exist to see if it lists columns in error? No.
        // Let's try to insert a dummy row or just guess?
        // Actually, let's try to fetch a single row from 'stations' or 'routes' to see how they look.
        console.log("No data in 'schedules' yet.");

        // Check routes too
        console.log("\nChecking 'routes' table...");
        const { data: routeData } = await supabase.from('routes').select('*').limit(1);
        if (routeData && routeData.length > 0) console.log("Route Columns:", Object.keys(routeData[0]));
    }
}

checkColumns();
