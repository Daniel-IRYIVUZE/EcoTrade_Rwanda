// components/ui/EmptyState.tsx — Empty state placeholder
import type { ReactNode } from 'react';

interface EmptyStateProps {
  icon?: ReactNode;
  title: string;
  description?: string;
  action?: ReactNode;
  compact?: boolean;
}

export default function EmptyState({ icon, title, description, action, compact = false }: EmptyStateProps) {
  return (
    <div className={`flex flex-col items-center justify-center text-center ${compact ? 'py-6' : 'py-12'} animate-fade-up`}>
      {icon && (
        <div className="w-14 h-14 flex items-center justify-center rounded-2xl bg-gray-100 dark:bg-gray-800 text-gray-400 dark:text-gray-500 mb-4">
          {icon}
        </div>
      )}
      <p className={`font-semibold text-gray-900 dark:text-white ${compact ? 'text-sm' : 'text-base'}`}>{title}</p>
      {description && (
        <p className={`text-gray-500 dark:text-gray-400 mt-1 max-w-xs ${compact ? 'text-xs' : 'text-sm'}`}>{description}</p>
      )}
      {action && <div className="mt-4">{action}</div>}
    </div>
  );
}
