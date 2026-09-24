<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CitizenReport;
use App\Models\GovernmentOffice;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class AdminCitizenReportController extends Controller
{
    // ─────────────────────────────────────────────────────────────────────
    // GET /api/admin/citizen-reports
    // Full list with filters for admin panel.
    // ─────────────────────────────────────────────────────────────────────
    public function index(Request $request): JsonResponse
    {
        $query = CitizenReport::with(['citizen', 'assignedOffice', 'activities'])
            ->orderBy('created_at', 'desc');

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }
        if ($request->filled('barangay')) {
            $query->where('barangay', $request->barangay);
        }
        if ($request->filled('search')) {
            $s = $request->search;
            $query->where(function ($q) use ($s) {
                $q->where('reference_number', 'like', "%{$s}%")
                  ->orWhere('concern', 'like', "%{$s}%")
                  ->orWhere('barangay', 'like', "%{$s}%");
            });
        }

        $reports = $query->paginate(25);

        return response()->json([
            'success' => true,
            'data'    => [
                'data'          => $reports->getCollection()->map(fn($r) => $r->toApiArray())->values(),
                'current_page'  => $reports->currentPage(),
                'last_page'     => $reports->lastPage(),
                'per_page'      => $reports->perPage(),
                'total'         => $reports->total(),
            ],
        ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    // GET /api/admin/citizen-reports/{id}
    // ─────────────────────────────────────────────────────────────────────
    public function show(int $id): JsonResponse
    {
        $report = CitizenReport::with(['citizen', 'assignedOffice', 'activities'])
            ->findOrFail($id);

        return response()->json(['success' => true, 'data' => $report->toApiArray()]);
    }

    // ─────────────────────────────────────────────────────────────────────
    // POST /api/admin/citizen-reports/{id}/validate
    // Admin validates: Submitted → Pending Validation → makes it public
    // ─────────────────────────────────────────────────────────────────────
    public function validate(int $id): JsonResponse
    {
        $report = CitizenReport::findOrFail($id);

        if ($report->status !== CitizenReport::STATUS_SUBMITTED
            && $report->status !== CitizenReport::STATUS_PENDING_VALIDATION) {
            return response()->json([
                'success' => false,
                'message' => 'Report is not in a validatable state.',
            ], 422);
        }

        $report->update(['is_public' => true]);

        // Only transition if not already at Pending Validation
        if ($report->status === CitizenReport::STATUS_SUBMITTED) {
            $report->transitionTo(CitizenReport::STATUS_PENDING_VALIDATION);
        }

        return response()->json([
            'success' => true,
            'message' => 'Report validated and published to community map.',
            'data'    => $report->fresh(['activities', 'assignedOffice'])->toApiArray(),
        ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    // POST /api/admin/citizen-reports/{id}/assign
    // Body: { office_id }
    // ─────────────────────────────────────────────────────────────────────
    public function assign(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'office_id' => 'required|exists:government_offices,id',
        ]);

        $report = CitizenReport::findOrFail($id);
        $office = GovernmentOffice::findOrFail($request->office_id);

        $report->update(['assigned_office_id' => $office->id]);
        $report->transitionTo(CitizenReport::STATUS_ASSIGNED, null, $office->name);

        return response()->json([
            'success' => true,
            'message' => "Report assigned to {$office->name}.",
            'data'    => $report->fresh(['activities', 'assignedOffice'])->toApiArray(),
        ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    // POST /api/admin/citizen-reports/{id}/status
    // Body: { status, description (optional) }
    // Admin can move status to any value in the flow.
    // ─────────────────────────────────────────────────────────────────────
    public function updateStatus(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'status'      => ['required', Rule::in(CitizenReport::STATUS_ORDER)],
            'description' => 'nullable|string|max:500',
        ]);

        $report = CitizenReport::findOrFail($id);
        $report->transitionTo($request->status, $request->description);

        return response()->json([
            'success' => true,
            'message' => 'Status updated.',
            'data'    => $report->fresh(['activities', 'assignedOffice'])->toApiArray(),
        ]);
    }

    // ─────────────────────────────────────────────────────────────────────
    // GET /api/admin/citizen-reports/map
    // All public reports with coordinates for map view.
    // ─────────────────────────────────────────────────────────────────────
    public function map(Request $request): JsonResponse
    {
        // ── CRITICAL: Only show reports that are ASSIGNED or later ───────
        // - Submitted: NOT on map (not approved)
        // - Pending Validation: NOT on map (approved but not assigned)
        // - Assigned+: YES on map (assigned to office, ready to track)
        $query = CitizenReport::with('assignedOffice')
            ->where('is_public', true)
            ->where('assigned_office_id', '!=', null)  // ← MUST be assigned to an office
            ->whereIn('status', [
                CitizenReport::STATUS_ASSIGNED,
                CitizenReport::STATUS_IN_PROGRESS,
                CitizenReport::STATUS_RESOLVED,
            ])
            ->whereNotNull('lat')
            ->whereNotNull('lng');

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        $reports = $query->get()->map(fn($r) => [
            'id'              => $r->id,
            'referenceNumber' => $r->reference_number,
            'category'        => $r->category,
            'concern'         => $r->concern,
            'status'          => $r->status,
            'barangay'        => $r->barangay,
            'lat'             => $r->lat,
            'lng'             => $r->lng,
            'assignedOffice'  => $r->assignedOffice?->name,
            'isPublic'        => $r->is_public,
        ]);

        return response()->json(['success' => true, 'data' => $reports]);
    }

    // ─────────────────────────────────────────────────────────────────────
    // GET /api/admin/citizen-reports/summary
    // Dashboard stat counts.
    // ─────────────────────────────────────────────────────────────────────
    public function summary(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data'    => [
                'total'              => CitizenReport::count(),
                'submitted'          => CitizenReport::where('status', CitizenReport::STATUS_SUBMITTED)->count(),
                'pending_validation' => CitizenReport::where('status', CitizenReport::STATUS_PENDING_VALIDATION)->count(),
                'assigned'           => CitizenReport::where('status', CitizenReport::STATUS_ASSIGNED)->count(),
                'in_progress'        => CitizenReport::where('status', CitizenReport::STATUS_IN_PROGRESS)->count(),
                'resolved'           => CitizenReport::where('status', CitizenReport::STATUS_RESOLVED)->count(),
            ],
        ]);
    }
}
