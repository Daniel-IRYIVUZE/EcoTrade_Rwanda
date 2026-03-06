// components/dashboard/Widget.tsx — EcoTrade SaaS dashboard widget
import type { ReactNode } from 'react';

interface DashboardWidgetProps {
  title: string;
  icon?: ReactNode;
  children: ReactNode;
  action?: ReactNode;
  /** Remove inner padding */
  flush?: boolean;
  /** Badge/counter next to title */
  badge?: string | number;
  badgeColor?: string;
  /** Footer content */
  footer?: ReactNode;
  /** Extra class names for container */
  className?: string;
  /** Loading skeleton overlay */
  loading?: boolean;
}

const DashboardWidget = ({
  title, icon, children, action, flush, badge, badgeColor, footer, className = '', loading,
}: DashboardWidgetProps) => {
  return (
    <div className={`bg-white dark:bg-gray-800 rounded-2xl border border-gray-200 dark:border-gray-700 shadow-sm overflow-hidden animate-fade-up ${className}`}>
      {/* Header */}
      <div className="flex items-center justify-between px-5 py-3.5 border-b border-gray-100 dark:border-gray-700">
        <div className="flex items-center gap-2.5">
          {icon && <span className="flex-shrink-0 text-cyan-600 dark:text-cyan-400">{icon}</span>}
          <h3 className="text-sm font-semibold text-gray-900 dark:text-white">{title}</h3>
          {badge !== undefined && (
            <span className={`px-1.5 py-0.5 rounded-full text-xs font-semibold ${badgeColor ?? 'bg-cyan-100 text-cyan-700 dark:bg-cyan-900/30 dark:text-cyan-300'}`}>
              {badge}
            </span>
          )}
        </div>
        {action && <div className="flex-shrink-0">{action}</div>}
      </div>

      {/* Body */}
      <div className={`relative ${flush ? '' : 'p-5'}`}>
        {loading && (
          <div className="absolute inset-0 bg-white/70 dark:bg-gray-800/70 z-10 flex items-center justify-center rounded-2xl">
            <div className="w-6 h-6 border-2 border-cyan-600 border-t-transparent rounded-full animate-spin" />
          </div>
        )}
        {children}
      </div>

      {/* Footer */}
      {footer && (
        <div className="px-5 py-3 border-t border-gray-100 dark:border-gray-700 bg-gray-50 dark:bg-gray-900/30">
          {footer}
        </div>
      )}
    </div>
  );
};

export default DashboardWidget;