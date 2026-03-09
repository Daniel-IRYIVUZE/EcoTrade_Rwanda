
const partners = [
  { name: 'REMA', logo: 'https://www.rema.gov.rw/fileadmin/user_upload/REMA/Icons_logos/Rema_logo.png', color: 'bg-white ' },
  { name: 'GGGI', logo: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJc0368IQVXP9wjuOj5t5L1Jyd9TGZa8SAZA&s', color: 'bg-white' },
  { name: 'COPED', logo: 'https://framerusercontent.com/images/sgtnwfAmpcPX5D6vtha1aCJB8jk.png?width=2164&height=1181', color: 'bg-white' },
  { name: 'ALU', logo: 'https://start.alueducation.com/resource/1568810909000/AluLogoForAdmissions', color: 'bg-white' },
  { name: 'Bank of Kigali', logo: 'https://seekvectorlogo.net/wp-content/uploads/2018/12/bank-of-kigali-vector-logo.png', color: 'bg-white' },
  { name: 'Rwanda Green Fund', logo: 'https://kigali.impacthub.net/wp-content/uploads/2024/10/Group-1037.png', color: 'bg-white' },
];

const PartnersCarousel = () => {
  return (
    <section className="py-16 bg-white dark:bg-gray-950 border-y border-gray-100 dark:border-gray-800 transition-colors duration-300 overflow-hidden">
      <div className="max-w-11/12 mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-10">
          <p className="text-sm font-semibold text-cyan-600 uppercase tracking-wider">
            Trusted by
          </p>
          <h3 className="text-2xl font-bold text-gray-900 dark:text-white">
            Leading Organizations in Rwanda's Circular Economy
          </h3>
        </div>

        <div className="relative">
          {/* Gradient overlays for fade effect */}
          <div className="absolute left-0 top-0 bottom-0 w-24 bg-gradient-to-r from-white dark:from-gray-950 to-transparent z-10 pointer-events-none"></div>
          <div className="absolute right-0 top-0 bottom-0 w-24 bg-gradient-to-l from-white dark:from-gray-950 to-transparent z-10 pointer-events-none"></div>

          {/* Animated Carousel */}
          <div className="overflow-hidden">
            <div className="flex animate-slide space-x-12">
              {/* First set */}
              {partners.map((partner, index) => (
                <PartnerLogo key={`first-${index}`} partner={partner} />
              ))}
              {/* Duplicate set for seamless loop */}
              {partners.map((partner, index) => (
                <PartnerLogo key={`second-${index}`} partner={partner} />
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

const PartnerLogo = ({ partner }: { partner: typeof partners[0] }) => (
  <div className="flex-shrink-0 flex items-center justify-center h-20 w-40 opacity-70 hover:opacity-100 transition-all duration-300 cursor-pointer">
    <div className={`h-16 w-36 rounded-xl ${partner.color} flex items-center justify-center shadow-md hover:shadow-lg transition-shadow overflow-hidden`}>
      {partner.logo ? (
        <img 
          src={partner.logo} 
          alt={`${partner.name} logo`}
          className="w-full h-full object-contain p-2"
          onError={(e) => {
            const target = e.target as HTMLImageElement;
            target.style.display = 'none';
            target.parentElement!.innerHTML += `<span class="text-white font-bold text-sm tracking-wider">${partner.name.split(' ').map(n => n[0]).join('')}</span>`;
          }}
        />
      ) : (
        <span className="text-white font-bold text-sm tracking-wider">
          {partner.name.split(' ').map(n => n[0]).join('')}
        </span>
      )}
    </div>
  </div>
);

export default PartnersCarousel;