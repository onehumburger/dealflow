export default function DealsLoading() {
  return (
    <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6">
      <div className="flex items-center justify-between">
        <div className="h-8 w-24 animate-pulse rounded bg-muted" />
        <div className="h-9 w-28 animate-pulse rounded bg-muted" />
      </div>
      <div className="mt-6 rounded-lg border bg-card">
        {/* Table header skeleton */}
        <div className="flex gap-4 border-b p-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <div
              key={i}
              className="h-4 flex-1 animate-pulse rounded bg-muted"
            />
          ))}
        </div>
        {/* Table rows skeleton */}
        {[1, 2, 3, 4, 5].map((i) => (
          <div key={i} className="flex gap-4 border-b p-4 last:border-b-0">
            {[1, 2, 3, 4, 5].map((j) => (
              <div
                key={j}
                className="h-4 flex-1 animate-pulse rounded bg-muted"
              />
            ))}
          </div>
        ))}
      </div>
    </div>
  );
}
