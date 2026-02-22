import { supabase } from './supabase';

/**
 * Minimal database helper logic.
 * Add your new data fetching logic here.
 */
export const db = {
    // Example: Fetch users
    async getUsers() {
        const { data, error } = await supabase.from('users').select('*').order('full_name');
        if (error) throw error;
        return data;
    },
};
