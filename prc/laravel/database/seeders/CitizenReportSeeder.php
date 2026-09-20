<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class CitizenReportSeeder extends Seeder
{
    /**
     * Intentionally empty.
     *
     * Dummy citizen reports have been removed so the admin panel only shows
     * real submissions from the Flutter app.
     * Run  php artisan reports:clear-dummy  to wipe any previously seeded data.
     */
    public function run(): void
    {
        $this->command->info('CitizenReportSeeder — skipped (no dummy data).');
    }
}
