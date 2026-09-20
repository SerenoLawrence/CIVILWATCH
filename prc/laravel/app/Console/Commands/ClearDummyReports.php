<?php

namespace App\Console\Commands;

use App\Models\Citizen;
use App\Models\CitizenReport;
use App\Models\ReportActivity;
use App\Models\CitizenNotification;
use Illuminate\Console\Command;

class ClearDummyReports extends Command
{
    /**
     * The artisan signature.
     *
     * Usage:
     *   php artisan reports:clear-dummy           — dry-run, shows what would be deleted
     *   php artisan reports:clear-dummy --force   — actually deletes
     */
    protected $signature = 'reports:clear-dummy
                            {--force : Skip confirmation and delete immediately}';

    protected $description = 'Delete all seeded dummy citizen reports (CW-2026-001xx) and their fake citizen accounts';

    /**
     * Reference numbers inserted by CitizenReportSeeder.
     * Add any extra ones here if you seeded more in other runs.
     */
    private const DUMMY_REFS = [
        'CW-2026-00101',
        'CW-2026-00102',
        'CW-2026-00103',
        'CW-2026-00104',
        'CW-2026-00105',
        'CW-2026-00106',
        'CW-2026-00107',
        'CW-2026-00108',
        'CW-2026-00109',
        'CW-2026-00110',
    ];

    /**
     * Phone numbers of the three fake citizens created by CitizenReportSeeder.
     */
    private const DUMMY_PHONES = [
        '639123456789',  // Juan Dela Cruz
        '639234567890',  // Maria Santos
        '639345678901',  // Pedro Reyes
    ];

    public function handle(): int
    {
        // ── Identify what will be removed ────────────────────────────────
        $reports = CitizenReport::whereIn('reference_number', self::DUMMY_REFS)->get();

        if ($reports->isEmpty()) {
            $this->info('✓ No dummy reports found. Nothing to delete.');
            return self::SUCCESS;
        }

        $reportIds = $reports->pluck('id');

        $activityCount      = ReportActivity::whereIn('citizen_report_id', $reportIds)->count();
        $notificationCount  = CitizenNotification::whereIn('citizen_report_id', $reportIds)->count();
        $dummyCitizens      = Citizen::whereIn('phone', self::DUMMY_PHONES)->get();

        // ── Show summary ──────────────────────────────────────────────────
        $this->newLine();
        $this->line('<fg=yellow>── Dummy data found ──────────────────────────────────────</>');
        $this->line("  Reports      : <fg=red>{$reports->count()}</>");
        $this->line("  Activities   : <fg=red>{$activityCount}</>");
        $this->line("  Notifications: <fg=red>{$notificationCount}</>");
        $this->line("  Fake citizens: <fg=red>{$dummyCitizens->count()}</>");
        $this->newLine();

        foreach ($reports as $r) {
            $this->line("  <fg=gray>[{$r->reference_number}]</> {$r->concern} — {$r->barangay} ({$r->status})");
        }
        $this->newLine();

        // ── Confirm unless --force ────────────────────────────────────────
        if (! $this->option('force')) {
            if (! $this->confirm('Delete all of the above? This cannot be undone.', false)) {
                $this->warn('Aborted. No data was deleted.');
                return self::SUCCESS;
            }
        }

        // ── Delete in safe order (children before parents) ────────────────
        $deleted = 0;

        $deleted += CitizenNotification::whereIn('citizen_report_id', $reportIds)->delete();
        $deleted += ReportActivity::whereIn('citizen_report_id', $reportIds)->delete();
        $deleted += CitizenReport::whereIn('reference_number', self::DUMMY_REFS)->delete();

        // Only remove a fake citizen if they have NO remaining real reports
        foreach ($dummyCitizens as $citizen) {
            $remaining = CitizenReport::where('citizen_id', $citizen->id)->count();
            if ($remaining === 0) {
                $citizen->tokens()->delete();   // revoke any Sanctum tokens
                $citizen->delete();
                $deleted++;
                $this->line("  Removed fake citizen: {$citizen->full_name} ({$citizen->phone})");
            } else {
                $this->warn("  Kept citizen {$citizen->full_name} — they still have {$remaining} real report(s).");
            }
        }

        $this->newLine();
        $this->info("✓ Done. {$deleted} rows deleted. Admin panel will now show only real submissions.");
        $this->newLine();

        return self::SUCCESS;
    }
}
