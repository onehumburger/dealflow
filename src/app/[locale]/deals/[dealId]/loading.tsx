export default function DealDetailLoading() {
  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      {/* Back link + header */}
      <div className="mb-4 h-4 w-16 animate-pulse rounded bg-muted" />
      <div className="mb-2 h-8 w-64 animate-pulse rounded bg-muted" />
      <div className="mb-6 flex gap-2">
        <div className="h-5 w-20 animate-pulse rounded-full bg-muted" />
        <div className="h-5 w-24 animate-pulse rounded-full bg-muted" />
        <div className="h-5 w-16 animate-pulse rounded-full bg-muted" />
      </div>

      {/* Milestones skeleton */}
      <div className="mb-6 rounded-lg border bg-card p-4">
        <div className="mb-3 h-5 w-28 animate-pulse rounded bg-muted" />
        <div className="flex gap-3 overflow-hidden">
          {[1, 2, 3, 4].map((i) => (
            <div
              key={i}
              className="h-16 w-36 shrink-0 animate-pulse rounded bg-muted"
            />
          ))}
        </div>
      </div>

      {/* Two-column layout */}
      <div className="grid gap-6 lg:grid-cols-3">
        {/* Main content */}
        <div className="space-y-6 lg:col-span-2">
          {/* Workstreams + Tasks */}
          <div className="rounded-lg border bg-card p-4">
            <div className="mb-3 h-5 w-24 animate-pulse rounded bg-muted" />
            <div className="space-y-3">
              {[1, 2, 3].map((i) => (
                <div key={i} className="space-y-2">
                  <div className="h-5 w-40 animate-pulse rounded bg-muted" />
                  <div className="ml-4 space-y-2">
                    {[1, 2].map((j) => (
                      <div
                        key={j}
                        className="h-4 animate-pulse rounded bg-muted"
                      />
                    ))}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
        {/* Sidebar: Activity */}
        <div className="rounded-lg border bg-card p-4">
          <div className="mb-3 h-5 w-20 animate-pulse rounded bg-muted" />
          <div className="space-y-3">
            {[1, 2, 3, 4].map((i) => (
              <div key={i} className="flex items-start gap-2">
                <div className="h-6 w-6 animate-pulse rounded-full bg-muted" />
                <div className="flex-1 space-y-1">
                  <div className="h-3 w-3/4 animate-pulse rounded bg-muted" />
                  <div className="h-3 w-1/2 animate-pulse rounded bg-muted" />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
