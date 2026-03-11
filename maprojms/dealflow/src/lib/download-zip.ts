export function downloadDocumentsZip(params: {
  dealId: string;
  workstreamId?: string;
  taskId?: string;
}) {
  const url = new URL("/api/documents/bulk-download", window.location.origin);
  url.searchParams.set("dealId", params.dealId);
  if (params.workstreamId) url.searchParams.set("workstreamId", params.workstreamId);
  if (params.taskId) url.searchParams.set("taskId", params.taskId);
  window.open(url.toString(), "_blank");
}
