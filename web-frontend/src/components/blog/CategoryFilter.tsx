// components/blog/CategoryFilter.tsx
interface CategoryFilterProps {
  activeCategory: string;
  setActiveCategory: (category: string) => void;
}

const categories = [
  'All',
  'Circular Economy',
  'Success Stories',
  'Technology',
  'Policy & Regulation',
  'Tips & Guides',
  'Interviews',
  'Research'
];

const CategoryFilter = ({ activeCategory, setActiveCategory }: CategoryFilterProps) => {
  return (
    <div className="mb-8">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Categories</h3>
      <div className="flex flex-wrap gap-2">
        {categories.map((category) => (
          <button
            key={category}
            onClick={() => setActiveCategory(category)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition-all duration-300 ${
              activeCategory === category
                ? 'bg-cyan-600 text-white shadow-lg scale-105'
                : 'bg-white text-gray-700 hover:bg-cyan-50 hover:text-cyan-700 border border-gray-200'
            }`}
          >
            {category}
          </button>
        ))}
      </div>
    </div>
  );
};

export default CategoryFilter;