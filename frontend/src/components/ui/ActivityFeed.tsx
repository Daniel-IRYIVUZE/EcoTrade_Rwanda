// components/ui/ActivityFeed.tsx — Real-time activity feed widget
import type { ReactNode } from 'react';

export interface ActivityItem {
  id: string;
  icon: ReactNode;
  iconBg?: string;
  title: string;
  subtitle?: string;
  time: string;
  badge?: string;
  badgeColor?: string;
}

interface ActivityFeedProps {
  items: ActivityItem[];
  maxItems?: number;
  emptyText?: string;
}

export default function ActivityFeed({ items, maxItems = 8, emptyText = 'No recent activity' }: ActivityFeedProps) {
  const visible = items.slice(0, maxItems);

  if (!visible.length) {
    return (
      <div className="py-8 text-center text-gray-400 dark:text-gray-500 text-sm">
        {emptyText}
      </div>
    );
  }

  return (
    <div className="relative">
      {/* Vertical timeline line */}
      <div className="absolute left-5 top-4 bottom-4 w-px bg-gray-100 dark:bg-gray-700" />

      <div className="space-y-1">
        {visible.map((item, i) => (
          <div
            key={item.id}
            className="flex items-start gap-3 py-2.5 px-2 rounded-xl hover:bg-gray-50 dark:hover:bg-gray-700/30 transition-colors duration-100 animate-fade-up"
            style={{ animationDelay: `${i * 40}ms` }}
          >
            {/* Icon bubble */}
            <div
              className={`w-7 h-7 flex items-center justify-center rounded-lg flex-shrink-0 z-10 text-white text-xs ring-2 ring-white dark:ring-gray-800 ${item.iconBg ?? 'bg-cyan-600'}`}
            >
              {item.icon}
            </div>

            {/* Content */}
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between gap-2">
                <p className="text-sm font-medium text-gray-900 dark:text-white truncate">{item.title}</p>
                {item.badge && (
                  <span className={`text-xs px-1.5 py-0.5 rounded-md font-medium flex-shrink-0 ${item.badgeColor ?? 'bg-cyan-100 text-cyan-700 dark:bg-cyan-900/30 dark:text-cyan-300'}`}>
                    {item.badge}
                  </span>
                )}
              </div>
              {item.subtitle && (
                <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5 truncate">{item.subtitle}</p>
              )}
              <p className="text-xs text-gray-400 dark:text-gray-600 mt-0.5">{item.time}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
