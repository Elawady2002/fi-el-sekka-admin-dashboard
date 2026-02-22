const { createClient } = require('@supabase/supabase-js');

// Manually provided from previous logs/env
const SUPABASE_URL = "https://pobcyzoegcthaqrpacau.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvYmN5em9lZ2N0aGFxcnBhY2F1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQzMjE1OTMsImV4cCI6MjA3OTg5NzU5M30.Q4kMbU86-F7f0nuYP2YpfAkmwZ4bPqOFpmC0xxG83-c";

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function checkColumns() {
    try {
        console.log("Checking columns for 'bookings' table...");
        const { data, error } = await supabase.from('bookings').select('*').limit(1);
        if (error) {
            console.error("Error fetching from bookings:", error);
        } else if (data && data.length > 0) {
            console.log("Booking Columns:", Object.keys(data[0]));
        } else {
            console.log("No data in 'bookings' yet.");
        }

        console.log("\nChecking stations table for column names...");
        const { data: stationsData } = await supabase.from('stations').select('*').limit(1);
        if (stationsData && stationsData.length > 0) {
            console.log("Station Columns:", Object.keys(stationsData[0]));
        }
    } catch (e) {
        console.error("Script failed:", e);
    }
}

checkColumns();
