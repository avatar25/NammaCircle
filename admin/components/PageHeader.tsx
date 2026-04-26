export function PageHeader({
  title,
  description
}: {
  title: string;
  description: string;
}) {
  return (
    <header className="mb-6">
      <h1 className="text-2xl font-semibold tracking-tight text-neutral-950">{title}</h1>
      <p className="mt-2 max-w-3xl text-sm text-neutral-600">{description}</p>
    </header>
  );
}
