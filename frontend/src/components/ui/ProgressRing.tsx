// components/ui/ProgressRing.tsx — Circular SVG progress indicator
import { useEffect, useState } from 'react';

interface ProgressRingProps {
  /** 0-100 */
  value: number;
  size?: number;
  strokeWidth?: number;
  color?: string;
  trackColor?: string;
  label?: string;
  sublabel?: string;
  showValue?: boolean;
  animate?: boolean;
}

export default function ProgressRing({
  value,
  size = 120,
  strokeWidth = 10,
  color = '#0891b2',
  trackColor,
  label,
  sublabel,
  showValue = true,
  animate = true,
}: ProgressRingProps) {
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;
  const [progress, setProgress] = useState(animate ? 0 : value);

  useEffect(() => {
    if (!animate) { setProgress(value); return; }
    const id = setTimeout(() => setProgress(value), 120);
    return () => clearTimeout(id);
  }, [value, animate]);

  const offset = circumference - (progress / 100) * circumference;
  const cx = size / 2;
  const cy = size / 2;

  const track = trackColor ?? (color + '26'); // 15% opacity of color

  return (
    <div className="flex flex-col items-center gap-1">
      <div className="relative" style={{ width: size, height: size }}>
        <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
          {/* Track */}
          <circle
            cx={cx} cy={cy} r={radius}
            fill="none"
            stroke={track}
            strokeWidth={strokeWidth}
          />
          {/* Progress arc */}
          <circle
            cx={cx} cy={cy} r={radius}
            fill="none"
            stroke={color}
            strokeWidth={strokeWidth}
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={offset}
            style={{ transition: animate ? 'stroke-dashoffset 1.1s cubic-bezier(0.34,1.56,0.64,1)' : 'none' }}
          />
        </svg>

        {/* Center text */}
        {showValue && (
          <div className="absolute inset-0 flex flex-col items-center justify-center">
            <span className="text-2xl font-extrabold tabular-nums" style={{ color }}>
              {Math.round(progress)}
            </span>
            {label && <span className="text-xs font-medium text-gray-500 dark:text-gray-400 mt-0.5">{label}</span>}
          </div>
        )}
      </div>
      {sublabel && (
        <p className="text-xs text-gray-500 dark:text-gray-400 text-center">{sublabel}</p>
      )}
    </div>
  );
}
