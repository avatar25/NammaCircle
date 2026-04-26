export function StatusButton({
  action,
  id,
  status,
  label
}: {
  action: (formData: FormData) => Promise<void>;
  id: string;
  status: string;
  label: string;
}) {
  return (
    <form action={action}>
      <input name="id" type="hidden" value={id} />
      <input name="status" type="hidden" value={status} />
      <button className="rounded-md border border-stone-300 bg-white px-3 py-1.5 text-xs font-medium hover:bg-stone-100">
        {label}
      </button>
    </form>
  );
}
